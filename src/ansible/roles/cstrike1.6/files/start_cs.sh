#!/bin/bash

DATE=$(date)
echo "${DATE}: Starting cstrike" >> /tmp/cstrike.log
cd /home/ubuntu/.steam/steamcmd/cs16server/
./hlds_run -game cstrike +ip 0.0.0.0 +maxplayers 12 +map de_dust2 -insecure
echo "${DATE}: Shutting down strike" >> /tmp/cstrike.log