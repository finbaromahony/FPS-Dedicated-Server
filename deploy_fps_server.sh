#!/bin/bash

#######################################
# Get SERVER_IP out of terraform output.
# Globals:
#   None
# Arguments:
#   None
#######################################
function get_server_ip_from_terraform_output() {
    make output
    SERVER_IP=$(jq '.server_ip.value' ./terraform_output.json | sed 's/\"//g')
}


#######################################
# Generate a random balue consisting of letters and numbers 32 characters long.
# Globals:
#   None
# Arguments:
#   None
#######################################
function random() {
    echo $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
}

#######################################
# Set Required Defaults.
# Globals:
#   RCON_PASSWORD
#   SV_PASSWORD
#   HOSTNAME
#   CONDITION_ZERO
#   COUNTER_STRIKE
#   GLOBAL_OFFENSIVE
#   PAVLOV_SHACK
# Arguments:
#   None
#######################################
function set_required_defaults() {
    [ -n "${HOSTNAME}" ] || { echo "Setting HOSTNAME to FPS-Server"; HOSTNAME="FPS-Server"; }
    if [[ "${FPS_FAMILY}" == "CS" ]]
    then
        echo "Set Counter Strike Defaults if Necessary"
        [ -n "${RCON_PASSWORD}" ] || { echo "Setting RCON_PASSWORD to Random value"; RCON_PASSWORD=$(random); }
        [ -n "${SV_PASSWORD}" ] || { echo "Setting SV_PASSWORD to \"\""; SV_PASSWORD='""'; }
        [ -n "${API_KEY}" ] || { echo "Setting API_KEY to \"\""; API_KEY='""'; }
    elif [[ "${FPS_FAMILY}" == "PAVLOV" ]]
    then
        echo "Set Pavlov VR Defaults if Necessary"
        [ -n "${SV_PASSWORD}" ] || { echo "Setting SV_PASSWORD to 0000"; SV_PASSWORD=0000; }
        check_sv_password_suitable_for_pavlov
    fi

    if [[ ${CONDITION_ZERO} == 1 ]]
    then
        INSTALLATION_TYPE="condition_zero"
    elif [[ ${COUNTER_STRIKE} == 1 ]]
    then
        INSTALLATION_TYPE="counter_strike"
    elif [[ ${GLOBAL_OFFENSIVE} == 1 ]]
    then
        INSTALLATION_TYPE="global_offensive"
    elif [[ ${PAVLOV_SHACK} == 1 ]]
    then
        INSTALLATION_TYPE="pavlov_shack"
    else
        INSTALLATION_TYPE="none"
    fi 
}


#######################################
# Generate ansible inventory file.
# Globals:
#   SSH_KEY_FILE
#   SERVER_IP
#   ANSIBLE_PATH
#   RCON_PASSWORD
#   SV_PASSWORD
#   HOSTNAME
#   INSTALLATION_TYPE
#   API_KEY
# Arguments:
#   None
#######################################
function generate_inventory() {
    echo "Generate Inventory file"
    echo "[all:vars]
ansible_connection=ssh
ansible_private_key_file=${SSH_KEY_FILE}
[fps]
server_ip ansible_host=${SERVER_IP}
[fps:vars]
ansible_user=ubuntu
rcon_password=${RCON_PASSWORD}
sv_password=${SV_PASSWORD}
server_hostname=${HOSTNAME}
installation_type=${INSTALLATION_TYPE}
api_key=${API_KEY}
ansible_python_interpreter=/usr/bin/python3" > "${ANSIBLE_PATH}/fps_inventory"


}

#######################################
# Run ansible to install and configure dedicated counter strike server
# Globals:
#   ANSIBLE_PATH
#   COUNTER_STRIKE
#   CONDITION_ZERO
#   GLOBAL_OFFENSIVE
#   PAVLOV_SHACK
# Arguments:
#   None
# Returns:
#   None
#######################################
function run_ansible() {
    if [ -n "${COUNTER_STRIKE}" ]
    then
        echo "Run ansible to install Counter Strike dedicated server on instance"
        /usr/bin/ansible-playbook -i "${ANSIBLE_PATH}"/fps_inventory \
                                     "${VLOGGING}" \
                                     "${ANSIBLE_PATH}"/cstrike.yml
    fi
    if [ -n "${CONDITION_ZERO}" ]
    then
        echo "Run ansible to install Counter Strike Condition Zero dedicated server on instance"
        /usr/bin/ansible-playbook -i "${ANSIBLE_PATH}"/fps_inventory \
                                     "${VLOGGING}" \
                                     "${ANSIBLE_PATH}"/cscz.yml
    fi
    if [ -n "${GLOBAL_OFFENSIVE}" ]
    then
        echo "Run ansible to install Counter Strike Global Offensive dedicated server on instance"
        /usr/bin/ansible-playbook -i "${ANSIBLE_PATH}"/fps_inventory \
                                     "${VLOGGING}" \
                                     "${ANSIBLE_PATH}"/csgo.yml
    fi
    if [ -n "${PAVLOV_SHACK}" ]
    then
        echo "Run ansible to install Pavlov-Shack dedicated server on instance"
        /usr/bin/ansible-playbook -i "${ANSIBLE_PATH}"/fps_inventory \
                                     "${VLOGGING}" \
                                     "${ANSIBLE_PATH}"/pavlov_shack.yml
    fi
}


#######################################
# Check required variables are available
# Globals:
#   ANSIBLE_PATH
#   SSH_KEY_FILE
#   SERVER_IP
#   GLOBAL_OFFENSIVE
#   API_KEY
# Arguments:
#   None
# Returns:
#   None
#######################################
function check_required_variables_are_available () {
    [ -n "${SERVER_IP}" ] || { echo "variable SERVER_IP does not exist; abort!"; exit 1; }
    [ -n "${ANSIBLE_PATH}" ] || { echo "variable ANSIBLE_PATH does not exist; abort!"; exit 1; }
    [ -n "${SSH_KEY_FILE}" ] || { echo "variable SSH_KEY_FILE does not exist; abort!"; exit 1; }
    if [ -n "${GLOBAL_OFFENSIVE}" ]
    then
        [ -n "${API_KEY}" ] || { echo "variable API_KEY does not exist and is required for CSGO; abort!"; exit 1; }
    fi
    
}

#######################################
# Check pavlov password is suitable
# They need to be 4 digit integers
# Globals:
#   SV_PASSWORD
# Arguments:
#   None
# Returns:
#   None
#######################################
function check_sv_password_suitable_for_pavlov () {
    TEST_PASSWORD=$(echo $SV_PASSWORD | sed 's/^[0-9][0-9][0-9][0-9]$//g')
    [ -n "${TEST_PASSWORD}" ] && { echo "${SV_PASSWORD} not suitable for pavlov, 4 digit integer required"; exit 1; }
}


#######################################
# check if ssh running on deployed instance
# Globals:
#   SERVER_IP
#   SSH_KEY_FILE
# Arguments:
#   None
# Returns:
#   None
#######################################
function can_i_login() {
    echo "fps server ip address is ${SERVER_IP}"
    count=20
    while [[ "${count}" -gt 0 ]]
    do
        if ssh -o BatchMode=yes \
        -o StrictHostKeyChecking=no \
        -o ConnectTimeout=5 \
        -i "${SSH_KEY_FILE}" \
        ubuntu@"${SERVER_IP}" \
        echo "HOWDY GENTS"
        then
            echo "server is now avaible"
            break
        else
            echo "server is not available attempt number :${count}, waiting"
            ((count--))
            sleep 5
        fi
    done
}

#######################################
# Determine Family of FPS being deployed
# Globals:
#   COUNTER_STRIKE
#   CONDITION_ZERO
#   GLOBAL_OFFENSIVE
#   PAVLOV_SHACK
# Arguments:
#   None
# Returns:
#   None
#######################################
function set_family() {
    if [ -n "${COUNTER_STRIKE}" ] || [ -n "${CONDITION_ZERO}" ] || [ -n "${GLOBAL_OFFENSIVE}" ]
    then
        FPS_FAMILY="CS"
    elif [ -n "${PAVLOV_SHACK}" ]
    then
        FPS_FAMILY="PAVLOV"
    fi
}

#######################################
# Determine the verbosity setting for ansible
# Globals:
#   VERBOSE
#   VLOGGING
# Arguments:
#   None
# Returns:
#   None
#######################################
function calculate_verbose_logging() {
    if [ -n "${VERBOSE}" ]
    then
        if [[ "${VERBOSE}" -eq 1 ]]
        then
            VLOGGING="-v"
        elif [[ "${VERBOSE}" -eq 2 ]]
        then
            VLOGGING="-vv"
        elif [[ "${VERBOSE}" -eq 3 ]]
        then
            VLOGGING="-vvv"
        else
            VLOGGING="-vvvv"
        fi
    else
        VLOGGING=""
    fi
}

#######################################
# Print instructions to connect to counter strike server
# Globals:
#   SERVER_IP
#   SV_PASSWORD
#   RCON_PASSWORD
# Arguments:
#   None
# Returns:
#   None
#######################################
function print_cs_instructions() {
    echo "Press ~ to open command console and type"
    echo "connect ${SERVER_IP}; password ${SV_PASSWORD}"
    echo "To change password on server"
    echo "    - Press ~ to open command console and type"
    echo "    - rcon_password ${RCON_PASSWORD}"
    echo "    - rcon sv_password \"<new password>\""
}

#######################################
# Print instructions to connect to pavlov server
# Globals:
#   HOSTNAME
#   SV_PASSWORD
# Arguments:
#   None
# Returns:
#   None
#######################################
function print_pavlov_instructions() {
    echo "Filter Serverlist to only show 'custom' servers"
    echo "Find Server named ${HOSTNAME}"
    echo "Password for Server is ${SV_PASSWORD}"
    echo "Review http://wiki.pavlov-vr.com/index.php?title=Dedicated_server"
    echo "or Discord for further details"
}

#######################################
# Print how script is used.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   None
#######################################
function print_help() {
    # Usage for using the script can be shown by using -h
    echo "[-h]
-d Deploy Infrastucture
-y Destroy Infrastructure
-c Install Counter Strike 1.6 Server
-z Install Counter Strike Condition Zero Server
-g Install Counter Strike Global Offensive Server
-s Install Pavlov Shack Server
[-a] Specify API_KEY value for CSGO
[-r] Specify RCON_PASSWORD value
[-p] Specify SV_PASSWORD value, or 4 digit integer password for Pavlov VR
[-n] Specify HOSTNAME value
[-v] Specify number to signify how verbose to be (up to 4)"
exit 0
}


PWD="$(pwd)"
ANSIBLE_PATH="${PWD}/src/ansible"
# for now we assume the key to use for communicating with server is called fps_dedicated_rsa
# and it resides in ~/.ssh
SSH_KEY_FILE="${HOME}/.ssh/fps_dedicated_rsa"

while getopts :hdyczgsa:r:p:n:v: option
do
    case "${option}"
    in
        h) print_help;;
        d) DEPLOY=1;;
        y) DESTROY=1;;
        c) COUNTER_STRIKE=1;;
        z) CONDITION_ZERO=1;;
        g) GLOBAL_OFFENSIVE=1;;
        s) PAVLOV_SHACK=1;;
        a) API_KEY=${OPTARG};;
        r) RCON_PASSWORD=${OPTARG};;
        p) SV_PASSWORD=${OPTARG};;
        n) HOSTNAME=${OPTARG};;
        v) VERBOSE=${OPTARG};;
        *) print_help;;
    esac
done

if [ -n "${DEPLOY}" ]
then
   make apply
fi

# Determine Family of FPS being deployed
set_family

if [ -n "${FPS_FAMILY}" ]
then
    get_server_ip_from_terraform_output
    check_required_variables_are_available
    can_i_login
    set_required_defaults
    generate_inventory
    calculate_verbose_logging
    run_ansible
    if [ "${FPS_FAMILY}" == "CS" ]
    then
        print_cs_instructions
    elif [ "${FPS_FAMILY}" == "PAVLOV" ]
    then
        print_pavlov_instructions
    fi
fi

if [ -n "${DESTROY}" ]
then
    make destroy
fi
