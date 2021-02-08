# FPS-Dedicated-Server
Deploy First Person Shooter Dedicated Server for use with a number of games
- Counter Strike 1.6
- Counter Strike Condition Zero
- Counter Strike Global Offensive
- Pavlov Shack (Quest 2 version)


## Table of Contents
- [Pre-requisites](#prereq)
- [help](#help)
- [installation](#installation)
  - [deploy instance](#deploy)
  - [Counter Strike 1.6](#one_point_six)
  - [Counter Strike Condition Zero](#zero)
  - [Counter Strike Global Offensive](#CSGO)
  - [Pavlov Shack (Quest)](#pavshack)
  - [Set Password & Hostname](#password_hostname)
- [Destroy Instance](#destroy)
- [Manage Instance](#manage)
- [Connect to instance](#connect)
- [Troubleshooting](#troubleshooting)
- [Known Issues](#known_issues)


## Pre-requisites <a name="prereq"></a>

Following instructions are for deploying from an Ubuntu Instance.

- Ansible is installed `sudo apt-get install ansible`
- You are authenticated with AWS and have credentials in ~/.aws/credentials
- You have installed awscli `sudo apt-get install awscli`
- You have upgraded awscli `pip install --upgrade awscli --user`
- You have generated a key-pair called `fps_dedicated_rsa` and have imported it to AWS as `cstrike`
  ```shell
  ssh-keygen -f ~/.ssh/fps_dedicated_rsa -t rsa -b 4096
  chmod 600 ~/.ssh/fps_dedicated_rsa
  # cat fps_dedicated_rsa.pub to get the string required for the public-key-material
  aws ec2 import-key-pair  --key-name fps_dedicated_rsa --public-key-material "ssh-rsa XXXXHXHHXHX youruser@yourdomain.com"
  ```

## Viewing Help <a name="help"></a>

Run `deploy_fps_server.sh` specifying the help command
```shell
[-h]
-d Deploy Infrastructure
-y Destroy Infrastructure
-c Install Counter Strike 1.6 Server
-z Install Counter Strike Condition Zero Server
-g Install Counter Strike Global Offensive Server
-s Install Pavlov Shack Server
[-a] Specify API_KEY value for CSGO
[-r] Specify RCON_PASSWORD value
[-p] Specify SV_PASSWORD value
[-n] Specify HOSTNAME value
```

## Install Dedicated Server Examples <a name="installation"></a>
The following is a number of examples for installing dedicated servers

### Deploying Instance <a name="deploy"></a>

Run `deploy_fps_server.sh` specifying the deploy command
```shell
./deploy_fps_server.sh -d
```
Alternatively you could run the Makefile directly
```shell
make apply
```
### Installing Counter Strike Dedicated Server 1.6 <a name="one_point_six"></a>

Run `deploy_fps_server.sh` specifying the install command
```shell
./deploy_fps_server.sh  -c -r <rcon_password>
```
### Installing Counter Strike Condition Zero Dedicated Server <a name="zero"></a>

Run `deploy_fps_server.sh` specifying the install command
```shell
./deploy_fps_server.sh -z -r <rcon_password>
```

### Installing Counter Strike Global Offensive Dedicated Server <a name="CSGO"></a>

Run `deploy_fps_server.sh` specifying the install command
```shell
./deploy_fps_server.sh -g -a <api_key>
```

### Specify server password and hostname [Optional] <a name="password_hostname"></a>

run `deploy_fps_server.sh` specifying install command with password and hostname
```shell
./deploy_fps_server.sh -z -r <rcon_password> -p <sv_password> -n <hostname>
```

### Connecting to Counter Strike Dedicated Server <a name="connect"></a>

Output of `deploy_fps_server.sh` will give the console command to run in counter-strike to run to access the server.
```shell
connect <SERVER_IP>
```

### Destroying the Counter Strike Dedicated Server <a name="destroy"></a>

Run `deploy_fps_server.sh` specifying the destroy command
```shell
./deploy_fps_server.sh -y
```

## Managing CSGO Dedicated Server <a name="manage"></a>

Recommended screen is used to manage running terminal instance.

```shell
## ssh to instance
ssh -i <ssh_key> ubuntu@<ip_address>
## start csgo server
## screen session recommended
/home/ubuntu/start_csgo.sh
```

## Known issues <a name="known_issues"></a>

Ansible is having issues installing CSGO...

It exits when steam is attempting to get "user info"
performing the operation manually does work.

## Troubleshooting <a name="troubleshooting"></a>

There are issues with the installation of components from time to time
This can happen with steam itself or with the installation/upgrade of a dedicated server

The `deploy_fps_server.sh` can be run as many times as required until the desired effect is obtained.

### Manual steps if CSGO installation fails

```shell
# log onto instance
ssh -i <ssh_key> ubuntu@<ip_address>
# run command to install CSGO
steamcmd +login anonymous +force_install_dir "./cs/" +app_update 740 validate +quit
# fill in start_csgo.j2 template and save it in /home/ubuntu as start_csgo.sh
```
