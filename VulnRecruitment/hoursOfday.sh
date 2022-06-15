#!/bin/bash

for i in $(seq -w 0 23)
do
  for j in $(seq -w 0 59)
  do
    hour="$i:$j"
    hash=$(echo -n $hour | md5sum | cut -d' ' -f 1)
    echo $hour >> dayHours.txt
    echo $hash >> dayHoursMD5.txt
  done
done
