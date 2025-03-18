#!/bin/bash


# Lekéri a létrehozott virtuális gépeket és formázza a szöveget használható formátumba
ids=( `pvesh get /cluster/resources --type vm | awk -F' |/' '{print $3}' | grep -v '^$'` )
idscount=${#ids[@]}
date=`date +"%Y%m%d"`
backupdir="/backup" # Write me
new_backupdir=$backupdir/$date
config_dir="/etc/pve/nodes/"`hostname`"/qemu-server"

mkdir -p $new_backupdir

# Csinál az összes virtuális eszközről egy mentést a /backup mappába
for ((i=0;i<idscount;i++))
 do
  cp $config_dir/${ids[i]}".conf" $new_backupdir/
  vzdump ${ids[i]} --mode snapshot --dumpdir $new_backupdir --compress zstd --node pve1tszt
  echo 'A backup sikeresen lefutott: '${ids[i]}'_backup-'$date' virtuális eszközön.'
  find $new_backupdir -type f "*-qemu-${ids[idscount]}-*"
done

# 100_NÉV_backup_2025_01_01
