# counter-strike-server
Deploy counter-strike-server for use with original version of counter-strike

## Pre-requisites

Following instructions are for deploying from an Ubuntu Instance.

- Ansible is installed `sudo apt-get install ansible`
- You are authenticated with AWS and have credentials in ~/.aws/credentials
- You have installed awscli `sudo apt-get install awscli`
- You have upgraded awscli `pip install --upgrade awscli --user`
- You have generated a key-pair called `cstrike_rsa` and have imported it to AWS as `cstrike`
  ```shell
  ssh-keygen
  chmod 600 cstrike_rsa
  # cat cstrike_rsa.pub to get the string required for the public-key-material
  aws ec2 import-key-pair  --key-name cstrike --public-key-material "ssh-rsa XXXXHXHHXHX youruser@yourdomain.com"
  ```

## Viewing Help

Run `deploy_cstrike_server.sh` specifying the help command
```shell
[-h]
-d Deploy Infrastructure
-y Destroy Infrastructure
-c Install Counter Strike 1.6 Server
-z Install Counter Strike Condition Zero Server
-g Install Counter Strike Global Offensive Server
[-a] Specify API_KEY value for CSGO
[-r] Specify RCON_PASSWORD value
[-p] Specify SV_PASSWORD value
[-n] Specify HOSTNAME value
```

## Deploying Instance

Run `deploy_cstrike_server.sh` specifying the deploy command
```shell
./deploy_cstrike_server.sh -d
```
Alternatively you could run the Makefile directly
```shell
make apply
```

## Installing Counter Strike Dedicated Server

Run `deploy_cstrike_server.sh` specifying the install command
```shell
./deploy_cstrike_server.sh  -c -r <rcon_password>
```
## Installing Counter Strike Condition Zero Dedicated Server

Run `deploy_cstrike_server.sh` specifying the install command
```shell
./deploy_cstrike_server.sh -z -r <rcon_password>
```

## Installing Counter Strike Global Offensive Dedicated Server

Run `deploy_cstrike_server.sh` specifying the install command
```shell
./deploy_cstrike_server.sh -g -a <api_key>
```

## Specify server password and hostname [Optional]

run `deploy_cstrike_server.sh` specifying install command with password and hostname
```shell
./deploy_cstrike_server.sh -z -r <rcon_password> -p <sv_password> -n <hostname>
```

## Connecting to Counter Strike Dedicated Server

Output of `deploy_strike_server.sh` will give the console command to run in counter-strike to run to access the server.
```shell
connect <SERVER_IP>
```

## Destroying the Counter Strike Dedicated Server

Run `deploy_cstrike_server.sh` specifying the destroy command
```shell
./deploy_cstrike_server.sh -y
```

## Managing CSGO Dedicated Server

Recommended screen is used to manage running terminal instance.

```shell
## ssh to instance
ssh -i <ssh_key> ubuntu@<ip_address>
## start csgo server
## screen session recommended
/home/ubuntu/start_csgo.sh
```

## Known issues

Ansible is having issues installing CSGO...

It exits when steam is attempting to get "user info"
performing the operation manually does work.

### Manual steps if CSGO installation fails

```shell
# log onto instance
ssh -i <ssh_key> ubuntu@<ip_address>
# run command to install CSGO
steamcmd +login anonymous +force_install_dir "./cs/" +app_update 740 validate +quit
# fill in start_csgo.j2 template and save it in /home/ubuntu as start_csgo.sh
```
