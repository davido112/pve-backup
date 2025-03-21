#!/bin/bash


# Lekéri a létrehozott virtuális gépeket és formázza a szöveget használható formátumba
ids=( `pvesh get /cluster/resources --type vm | awk -F' |/' '{print $3}' | grep -v '^$'` )
idscount=${#ids[@]}
date=`date +"%Y%m%d"`
backupdir="/backup" # Write me
new_backupdir=$backupdir/$date
config_dir="/etc/pve/nodes/"`hostname`"/qemu-server"

" args=(`$#`)
args_num=${#args[@]}
for (( i=0;i<args_num;i=i+2 ));
 do
  if ((args_num%2==0));
   then
    echo 'Some arguments are missing!'
    exit;
   fi;

  # If have backup dir make a variable
  if (( '-b'=$args[i] || '--backupdir'=$args[i] ));
   then
    backupdir=`$args[i+1]`
    continue;
   fi;

  if (( '-g'=$args[i] || '--guestname'=$args[i] ));
   then
    guestname=`$args[i+1]`
    continue;
   fi;
   
done"

# Remove old backups
find "$backupdir" -mtime +7 -exec rm -rf '{}' \;

# Make daystamped folder
mkdir -p $new_backupdir

# Csinál az összes virtuális eszközről egy mentést a /backup mappába
for ((i=0;i<idscount;i++))
 do
  cp $config_dir/${ids[i]}".conf" $new_backupdir/
  vzdump ${ids[i]} --mode snapshot --dumpdir $new_backupdir --compress zstd --node pve1tszt
  name=`cat $new_backupdir/${ids[i]}".conf" | grep "name: " | sed -e "s/name: //"`
  echo 'A backup sikeresen lefutott: '${ids[i]}'_backup-'$name'-'$date' virtuális eszközön.'
  find "$new_backupdir" -type f -name "*qemu-${ids[i]}*.vma.zst" -exec mv {} $new_backupdir/${ids[i]}'_backup-'$name'-'$date".vma.zst" \;
  find "$new_backupdir" -type f -name "*qemu-${ids[i]}*.log" -exec mv {} $new_backupdir/${ids[i]}'_backup-'$name'-'$date".log" \;
done
