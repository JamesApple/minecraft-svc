#!/bin/bash

rm -rf /tmp/mcbak
mkdir -p /tmp/mcbak

cp -r /home/minecraft/server/backups /tmp/mcbak
cp -r /home/minecraft/server/config /tmp/mcbak
cp /home/minecraft/server/server.properties /tmp/mcbak
cp /home/minecraft/server/banned-ips.json /tmp/mcbak
cp /home/minecraft/server/banned-ips.json /tmp/mcbak
cp /home/minecraft/server/ops.json /tmp/mcbak
cp /home/minecraft/server/ops.json /tmp/mcbak
cp /home/minecraft/server/whitelist.json /tmp/mcbak

tar -zcf /tmp/app-backup.tar.gz /tmp/mcbak

/usr/bin/gsutil cp  /tmp/app-backup.tar.gz gs://backups-japple-minecraft/app-backup.tar.gz
rm -rf /tmp/mcbak
rm -f /tmp/app-backup.tar.gz

echo 'Probably did a backup but idk'
