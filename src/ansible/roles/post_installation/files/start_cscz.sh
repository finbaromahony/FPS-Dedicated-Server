#!/bin/bash

DATE=$(date)
echo "${DATE}: Starting cscz" >> /tmp/cscz.log
cd /home/ubuntu/.steam/steamcmd/cs/
./hlds_run -game czero +ip 0.0.0.0 +maxplayers 12 +map de_aztec -insecure
echo "${DATE}: Shutting down cscz" >> /tmp/cscz.log