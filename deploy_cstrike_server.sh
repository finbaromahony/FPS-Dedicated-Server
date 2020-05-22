#!/bin/bash

#######################################
# Get SERVER_IP out of terraform output.
# Globals:
#   SERVER_IP
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
#   SERVER_IP
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
# Arguments:
#   None
#######################################
function set_required_defaults() {
    [ -n "${RCON_PASSWORD}" ] || { echo "Setting RCON_PASSWORD to Random value"; RCON_PASSWORD=$(random); }
    [ -n "${SV_PASSWORD}" ] || { echo "Setting SV_PASSWORD to \"\""; SV_PASSWORD='""'; }
    [ -n "${HOSTNAME}" ] || { echo "Setting HOSTANAME to CounterStrikeServer"; HOSTANAME="CounterStrikeServer"; }
    if [[ ${CONDITION_ZERO} == 1 ]]
    then
        INSTALLATION_TYPE="condition_zero"
    elif [[ ${COUNTER_STRIKE} == 1 ]]
    then
        INSTALLATION_TYPE="counter_strike"
    elif [[ ${GLOBAL_OFFENSIVE} ==1 ]]
    then
        INSTALLATION_TYPE="global_offensive"
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
# Arguments:
#   None
#######################################
function generate_inventory() {
    echo "Generate Inventory file"
    echo "[all:vars]
ansible_connection=ssh
ansible_private_key_file=${SSH_KEY_FILE}
[cstrike]
server_ip ansible_host=${SERVER_IP}
[cstrike:vars]
ansible_user=ubuntu
rcon_password=${RCON_PASSWORD}
sv_password=${SV_PASSWORD}
server_hostname=${HOSTNAME}
installation_type=${INSTALLATION_TYPE}
api_key=${API_KEY}
ansible_python_interpreter=/usr/bin/python3" > "${ANSIBLE_PATH}/cstrike_inventory"


}

#######################################
# Run ansible to install and configure dedicated counter strike server
# Globals:
#   ANSIBLE_PATH
#   COUNTER_STRIKE
#   CONDITION_ZERO
#   GLOBAL_OFFENSIVE
# Arguments:
#   None
# Returns:
#   None
#######################################
function run_ansible() {
    if [ -n "${COUNTER_STRIKE}" ]
    then
        echo "Run ansible to install Counter Strike dedicated server on instance"
        /usr/bin/ansible-playbook -i "${ANSIBLE_PATH}"/cstrike_inventory \
                                     "${ANSIBLE_PATH}"/cstrike.yml
    fi
    if [ -n "${CONDITION_ZERO}" ]
    then
        echo "Run ansible to install Counter Strike Condition Zero dedicated server on instance"
        /usr/bin/ansible-playbook -i "${ANSIBLE_PATH}"/cstrike_inventory \
                                     "${ANSIBLE_PATH}"/cscz.yml
    fi
    if [ -n "${GLOBAL_OFFENSIVE}" ]
    then
        echo "Run ansible to install Counter Strike Global Offensive dedicated server on instance"
        /usr/bin/ansible-playbook -i "${ANSIBLE_PATH}"/cstrike_inventory \
                                     "${ANSIBLE_PATH}"/csgo.yml
    fi
}


#######################################
# Check required variables are available
# Globals:
#   ANSIBLE_PATH
#   SSH_KEY_FILE
#   SERVER_IP
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
    echo "cstrike server ip address is ${SERVER_IP}"
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
# Print instructions to connect to counter strike server
# Globals:
#   SERVER_IP
# Arguments:
#   None
# Returns:
#   None
#######################################
function print_instructions() {
    echo "Press ~ to open command console and type"
    echo "connect ${SERVER_IP}; password ${SV_PASSWORD}"
    echo "To change password on server"
    echo "    - Press ~ to open command console and type"
    echo "    - rcon_password ${RCON_PASSWORD}"
    echo "    - rcon sv_password \"<password>\""
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
-g Install Counter Strike Global Offensive
[-a] Specify API_KEY value for CSGO
[-r] Specify RCON_PASSWORD value
[-p] Specify SV_PASSWORD value
[-n] Specify HOSTNAME value"
exit 0
}


PWD="$(pwd)"
ANSIBLE_PATH="${PWD}/src/ansible"
# for now we assume the key to use for communicating with server is called cstrike.pem
# and it resides in ~/.ssh
SSH_KEY_FILE="${HOME}/.ssh/cstrike_rsa"

while getopts :hdyczr:p:n: option
do
    case "${option}"
    in
        h) print_help;;
        d) DEPLOY=1;;
        y) DESTROY=1;;
        c) COUNTER_STRIKE=1;;
        z) CONDITION_ZERO=1;;
        g) GLOBAL_OFFENSIVE=1;;
        a) API_KEY=${OPTARG};;
        r) RCON_PASSWORD=${OPTARG};;
        p) SV_PASSWORD=${OPTARG};;
        n) HOSTNAME=${OPTARG};;
        *) print_help;;
    esac
done

if [ -n "${DEPLOY}" ]
then
   make apply
fi
if [ -n "${COUNTER_STRIKE}" ] || [ -n "${CONDITION_ZERO}" ] || [ -n "${GLOBAL_OFFENSIVE}" ]
then
    get_server_ip_from_terraform_output
    check_required_variables_are_available
    can_i_login
    set_required_defaults
    generate_inventory
    run_ansible
    print_instructions
fi
if [ -n "${DESTROY}" ]
then
    make destroy
fi
