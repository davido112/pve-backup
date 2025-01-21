
#!/bin/bash


# Lekéri a létrehozott virtuális gépeket és formázza a szöveget használható formátumba
ids=( `pvesh get /cluster/resources --type vm | awk -F' |/' '{print $3}' | grep -v '^$'` )
idscount=${#ids[@]}
date=`date +"%F"`

# Csinál az összes virtuális eszközről egy mentést a /backup mappába
for ((i=0;i<idscount;i++))
 do
  vzdump ${ids[i]} --mode snapshot --dunpdir /backup/  --remove 0 --storage local --compress zstd --notification-mode auto --notes-template ${ids[i]}_backup-$date --node pve1tszt
  echo 'A backup sikeresen lefutott: '${ids[i]}'_backup-'$date' virtuális eszközön.'
done
