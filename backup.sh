#!/bin/bash


# Lekéri a létrehozott virtuális gépeket és formázza a szöveget használható formátumba
ids=( `pvesh get /cluster/resources --type vm | awk -F' |/' '{print $3}' | grep -v '^$'` )
idscount=${#ids[@]}
date=`date +"%Y%M%D"`
backupdir="/backup" # Write me 
new_backupdir=$backupdir/$date
config_dir="/etc/pve/nodes/"`hostname`"/qemu-server"

# Csinál az összes virtuális eszközről egy mentést a /backup mappába
for ((i=0;i<idscount;i++))
 do
  cp $config_dir/${ids[i]}".conf"
  vzdump ${ids[i]} --mode snapshot --dunpdir $new_backupdir --compress zstd --node pve1tszt
  echo 'A backup sikeresen lefutott: '${ids[i]}'_backup-'$date' virtuális eszközön.'
done
