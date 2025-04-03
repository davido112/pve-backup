#!/bin/bash

#Usage:
#-b or --backupdir = Set a folder to move the backup
#-v or --vmid = Only the listed VMs will backuped. Enter a value separated by a comma! f.e: -v 100,101
#-s or --saveconfig = Need a bool value. Save the VM config to the backup dir
#-g or --generatedaystampfolder = In the backup folder create a daystamped folder. The command need a bool value! 
#-f or --filename = f.e: "{{vmid}}_backup_{{vmname}}'-'{{date}}"
#./backup.sh -b /backup/anything -v 100,101,102 -s 1 -g 1

# Check the created VMs and makes the text to usable format
ids=( `pvesh get /cluster/resources --type vm | awk -F' |/' '{print $3}' | grep -v '^$'` )
idscount=${#ids[@]}
date=`date +"%Y%m%d"`
backupdir="/backup" # Write me
new_backupdir=$backupdir/$date
config_dir="/etc/pve/nodes/"`hostname`"/qemu-server"
generatedaystampfolder=0
saveconfig=0
filename="{{vmid}}_backup_{{vmname}}'-'{{date}}"

args=("$@")
args_num=$#
for (( i=0;i<args_num;i++ ))
 do
  # Checking to odd or even arguments we have
  if (( $args_num%2!=0 ));
   then
    echo 'Some arguments are missing!'
    exit;
   fi;

  # If have backup dir make a variable
  if [[ '-b' == "${args[i]}" || '--backupdir' == "${args[i]}" ]];
   then
    backupdir=${args[i+1]}
    continue;
   fi;

   if [[ '-v' == "${args[i]}" || '--vmid' == "${args[i]}" ]];
   then
    vmid=${args[i+1]}
    IFStemp=$IFS
    IFS=","
    ids=(`echo $vmid`)
    IFS=$IFStemp
    continue;
   fi;

   if [[ '-s' == "${args[i]}" || '--saveconfig' == "${args[i]}" ]];
   then
    saveconfig=${args[i+1]}
    continue;
   fi;

   if [[ '-g' == "${args[i]}" || '--generatedaystampfolder' == "${args[i]}" ]];
   then
    generatedaystampfolder=${args[i+1]}
    continue;
   fi;

   if [[ '-f' == "${args[i]}" || '--filename' == "${args[i]}" ]];
   then
    filename=${args[i+1]}
    filename="${filename//\{\{date\}\}/$date}"
    echo $filename
    continue;
   fi;
done

# Remove old backups
find "$backupdir" -mtime +7 -exec rm -rf '{}' \;

# Make daystamped folder
if (( $generatedaystampfolder ))
 then
  mkdir -p $new_backupdir
 else
  mkdir -p $backupdir
  new_backupdir=$backupdir
fi;
# Make backup all of the VMs to the /backup folder
for ((i=0;i<idscount;i++))
 do
 name=`cat $config_dir/${ids[i]}".conf" | grep "name: " | sed -e "s/name: //"`
  if (( $saveconfig ));
   then
    cp $config_dir/${ids[i]}".conf" $new_backupdir/
    name=`cat $new_backupdir/${ids[i]}".conf" | grep "name: " | sed -e "s/name: //"`
  fi;
  
  vzdump ${ids[i]} --mode snapshot --dumpdir $new_backupdir --compress zstd
  echo $filename | sed -e "s/{{date}}/$date/g" -e "s/{{vmid}}/${ids[i]}/g" -e "s/{{vmname}}/$name/g"
  find "$new_backupdir" -type f -name "*qemu-${ids[i]}*.vma.zst" -exec mv {} $new_backupdir/$filename".vma.zst" \;
  find "$new_backupdir" -type f -name "*qemu-${ids[i]}*.log" -exec mv {} $new_backupdir/$filename".log" \;
  if [ -f $new_backupdir/${ids[i]}'_backup-'$name'-'$date".vma.zst" ]; then
   echo 'The backup was succesful: '${ids[i]}'_backup-'$name'-'$date'.'
  else
   echo 'The backup was failed: '${ids[i]}'_backup-'$name'-'$date'.'
  fi;
done
