
New-VMSwitch -Name nat-switch -SwitchType Internal -Verbose
Get-NetAdapter
New-NetIPAddress -IPAddress 192.168.100.1 -PrefixLength 24 -InterfaceIndex 28 -Verbose
New-NetNat -Name nat-switch -InternalIPInterfaceAddressPrefix 192.168.100.0/24 -Verbose
Get-NetNat
Get-VMSwitch

New-VMSwitch -SwitchName "NatSwitch" -SwitchType Internal
Get-NetAdapter
New-NetIPAddress -IPAddress 192.168.0.1 -PrefixLength 24 -InterfaceIndex 24
New-NetNat -Name NatSwitch -InternalIPInterfaceAddressPrefix 192.168.0.0/24

Get-NetIPAddress -InterfaceAlias "vEthernet (NatSwitch)"


#Configure Network Ubuntu
sudo lshw -class network
ip addr flush eth0
sudo dhclient eth1

#Firewall
sudo ufw allow ssh
sudo ufw enable
sudo ufw status


#Change DNS
vi /etc/hosts

#   192.168.0.3 workernode01
#   192.168.0.2 controlplane01
#   192.168.0.4 workernode02

sudo apt install net-tools

sudo hostnamectl set-hostname workernode02


#Enable NTP
sudo timedatectl set-ntp on

#change timezone
timedatectl
timedatectl list-timezones
sudo timedatectl set-timezone America/Bogota

#openssh-server
sudo apt-get install openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh

#change configuration Network
/etc/netplan/99_config.yaml

network:
  version:
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: true


sudo netplan apply

#Start interface
sudo ifconfig eth1 up
sudo ifconfig eth1 down

# shut down and bring up all networking
/etc/init.d/network stop
/etc/init.d/network start



network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      addresses:
        - 10.10.10.2/24
      gateway4: 10.10.10.1
      nameservers:
          search: [mydomain, otherdomain]
          addresses: [10.10.10.1, 1.1.1.1]


sudo apt install -y vim git bash-complation


## Commands git ##
git --version

git config --global user.name "ehbc"
git config --global user.email "ehbc@ehbc.com"

git config --list

echo "# devops" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/EdwinHarleyBermudezCuervo/devops.git
git push -u origin main

git remote add origin https://github.com/EdwinHarleyBermudezCuervo/devops.git
git branch -M main
git push -u origin main


#Generate token
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

git remote add origin https://github.com/EdwinHarleyBermudezCuervo/edwinharleybermudez.git
git init
git add .
git branch
git push -u origin master

username:edwinbermudez91
token: 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


git branch feature/ehbc