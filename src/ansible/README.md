`https://www.vultr.com/docs/how-to-install-counter-strike-1-6-server-linux`

First, download SteamCMD.

```
 mkdir SteamCMD
 cd SteamCMD
 wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
```
Next, obtain the 32-bit system libs. If your system uses yum, you can run the following command.

```
yum install glibc.i686 libstdc++.i686
Open the ports used by SteamCMD in your system firewall.

iptables -A INPUT -p udp -m udp --sport 27000:27030 --dport 1025:65355 -j ACCEPT
iptables -A INPUT -p udp -m udp --sport 4380 --dport 1025:65355 -j ACCEPT
```
Extract the files of the SteamCMD archive.
```
tar xvfz steamcmd_linux.tar.gz
```
Launch SteamCMD; you will see it download and install updates.
```
./steamcmd.sh
```
Download the game server software.
```
login anonymous 
```
Install CS 1.6 in a folder named "27020". The folder is named as the port that the server will run on. Steam uses the application ID of 90 for CS 1.6.
```
force_install_dir ./27020/
app_set_config 90 mod cstrike
app_update 90 validate
app_update 90 -beta beta validate
```
Quit SteamCMD.
```
exit
```
Now, try starting your Counter Strike 1.6 server.
```
cd 27020​
./hlds_run -console -game cstrike +port 27020 +map de_dust2 +maxplayers 32 -pingboost 1
```
At this point, the server will start and you can connect to it with your game client. Enjoy!