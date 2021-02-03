#!/bin/bash

###########################
# CSGO Updates
#
# CSGO is constantly requiring updates, so this script is to be run
# Periodically when the server suggests that an update is required.
###########################
echo "Ensure CSGO server is not running; otherwise update will fail"
ps -ef | grep srcds

steamcmd +login anonymous +force_install_dir "./cs/" +app_update 740 validate +quit

echo "Update Completed"
