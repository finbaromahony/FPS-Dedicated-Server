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
# Generate ansible inventory file.
# Globals:
#   SSH_KEY_FILE
#   SERVER_IP
#   ANSIBLE_PATH
# Arguments:
#   None
#######################################
function generate_inventory() {
    echo "[all:vars]
ansible_connection=ssh
ansible_private_key_file=${SSH_KEY_FILE}
[cstrike]
server_ip ansible_host=${SERVER_IP}
[cstrike:vars]
ansible_user=ec2-user" > "${ANSIBLE_PATH}/cstrike_inventory"
}

#######################################
# Run ansible to install and configure dedicated counter strike server
# Globals:
#   ANSIBLE_PATH
# Arguments:
#   None
# Returns:
#   None
#######################################
function run_ansible() {
    echo "run ansible to install cstrike dedicated server on instance"
    /usr/bin/ansible-playbook -i "${ANSIBLE_PATH}"/cstrike_inventory \
                                 "${ANSIBLE_PATH}"/cstrike.yml
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
        -i ${SSH_KEY_FILE} \
        ec2-user@"${SERVER_IP}" \
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
    echo "connect ${SERVER_IP}"
}

PWD="$(pwd)"
ANSIBLE_PATH="${PWD}/src/ansible"
# for now we assume the key to use for communicating with server is called cstrike.pem
# and it resides in ~/.ssh
SSH_KEY_FILE="~/.ssh/cstrike_rsa"

case "$1" in
    deploy)
        make apply
        ;;
    install)
        get_server_ip_from_terraform_output
        check_required_variables_are_available
        can_i_login
        generate_inventory
        run_ansible
        print_instructions
        ;;
    *)
        echo "${1} is not a supported command."
esac

