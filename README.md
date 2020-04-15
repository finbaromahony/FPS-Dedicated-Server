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
-d Deploy Infrastucture
-y Destroy Infrastructure
-c Install Counter Strike 1.6 Server
-z Install Counter Strike Condition Zero Server
-r Specify RCON_PASSWORD value
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
## Connecting to Counter Strike Dedicated Server

Output of `deploy_strike_server.sh` will give the console command to run in counter-strike to run to access the server.
```shell
connect <SERVER_IP>
```

### Destroying the Counter Strike Dedicated Server

Run `deploy_cstrike_server.sh` specifying the destroy command
```
./deploy_cstrike_server.sh -y
```
