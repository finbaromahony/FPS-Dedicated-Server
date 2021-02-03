#!/bin/bash

###########################
# Pavlov Shack Updates
#
# Pavlov Shack may require updates, so this script is to be run
# Periodically when the server suggests that an update is required.
###########################

steamcmd +login "anonymous" +force_install_dir "./pavlovserver" +app_update 622970 -beta shack +quit
echo "Update Completed"