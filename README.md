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

## Deploying Instance

Run `deploy_cstrike_server.sh` specifying the deploy command
```shell
./deploy_cstrike_server.sh deploy
```
Alternatively you could run the Makefile directly
```shell
make apply
```

## Installing Counter Strike Dedicated Server

Run `deploy_cstrike_server.sh` specifying the install command
```shell
./deploy_cstrike_server.sh install
```

## Connecting to Counter Strike Dedicated Server

Output of `deploy_strike_server.sh` will give the console command to run in counter-strike to run to access the server.
```shell
connect <SERVER_IP>
```