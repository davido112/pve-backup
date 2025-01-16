#! /bin/bash

next_id=`pvesh get /cluster/nextid`
max=${next_id:1:2} # ${sting:index:length}
date=`date +"%F"`


for (( i=0;i<$max;i++  ))
 do
  if (( $max <= 9  ))
   then
    write='0'$i
   fi
  #vzdump 10$i --mode snapshot --remove 0 --storage local --compress zstd --notification-mode auto --notes-template '1'$write'_backup-'$date --node pve1tszt
  echo 'A backup sikeresen lefutott: 1'$write'_backup-'$date' virtuális eszközön.'
done
