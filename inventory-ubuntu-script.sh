#!/bin/bash
####################################
#########Created By arunvignesh.Venkatesh@mindtree.com###########
####################################

#mkdir /inven-scripts/
#cd /inven-scripts/
#HOSTNAME :-
HOSTN=`/bin/hostname`
#OPERATING SYSTEM :-
OS=`cat /etc/os-release | grep PRETTY | cut -d "=" -f2`
#ARCHITECTURE :-
ARCH=`/bin/uname -p`
#HYPERVISOR TYPE
HTYPE=`dmidecode | grep -m 1 "Product Name" | cut -d ":" -f 2`
if [ "$HTYPE"  = " VMware Virtual Platform" ]
        then HTYPE="VMware Hypervisor"
else
        HTYPE="OTHERS"
fi

#HYPERVISOR MANUFACTURER :-
MANUFAC=`/usr/sbin/dmidecode --type system | grep Manufacturer | cut -d ":" -f2  | cut -d "," -f1`

#PRODUCT NAME :-
PRODUCTNAME=`/usr/sbin/dmidecode | grep "Product Name" | cut -d ":" -f2 | awk '$1=$1'`

#CPU Info/Type
CPUI=`cat /proc/cpuinfo | grep "model name" | cut -d ":" -f2 | uniq`

#CPU Usage
CPU=`top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}'`

#CPU Details
CPUOM=`/usr/bin/lscpu | grep "CPU op" | cut -d ":" -f2 | awk '$1=$1'`
CPUC=`/usr/bin/lscpu | grep -i "CPU(s):" | grep -v node | cut -d ":" -f2 | awk '$1=$1'`
CPUS=`/usr/bin/lscpu | grep -i "socket(s)" | cut -d ":" -f2 | awk '$1=$1'`
CPUMHZ=`/usr/bin/lscpu | grep -i "CPU MHz" | cut -d ":" -f2 | awk '$1=$1'`

#MEMORY DETAILS
#MEMUSAGE=`top -n 1 -b | grep "Mem"`
#MAXMEM1=`echo $MEMUSAGE | cut -d" " -f2 | awk '{print substr($0,1,length($0)-1)}'`
#MAXMEM=$(expr $MAXMEM1 / 1024)
#USEDMEM2=`echo $MEMUSAGE | cut -d" " -f4 | awk '{print substr($0,1,length($0)-1)}'`
#USEDMEM=$(expr $USEDMEM2 / 1024)
#USEDMEM1=`expr $USEDMEM \* 100`
#PERCENTAGE=`expr $USEDMEM1 / $MAXMEM`%

MAXMEM=`free -m | grep Mem | awk '{print $2}'`
USEDMEM=`free -m | grep Mem | awk '{print $3}'`

#SWAP DETAILS
SWAPFS=`swapon -s | grep -vE '^Filename' | awk '{ printf $1}'`
SWAPS1=`swapon -s | grep -vE '^Filename' | awk '{ printf $3}'`
SWAPS=$(expr $SWAPS1 / 1024)
SWAPU1=`swapon -s | grep -vE '^Filename' | awk '{ printf $4}'`
SWAPU=$(expr $SWAPU1 / 1024)
SWAPP1=`swapon -s | grep -vE '^Filename' | awk '{ printf $5}'`
SWAPP=$(expr $SWAPP1 / 1024)

#DISK
TOT_DISK=`fdisk -l | grep Disk | grep /dev/ | grep -v mapper | wc -l`
DISK=`df -H | grep -vE '^Filesystem|tmpfs|cdrom|none|udev' | awk '{ print $5 " " $2 " " $3 " " $1" | "}'`

#NETWORK DETAILS
IP=`ifconfig eth0 | grep "inet addr" | cut -d ":" -f2 | awk '{printf $1}'`
SM=`ifconfig eth0 | grep "inet addr" | cut -d ":" -f4`
MAC=`ifconfig eth0 | grep "HWaddr" | awk '{print $5}'`

IP2=`ifconfig eth1 | grep "inet addr" | cut -d ":" -f2 | awk '{printf $1}'`
SM2=`ifconfig eth1 | grep "inet addr" | cut -d ":" -f4`
MAC2=`ifconfig eth1 | grep "HWaddr" | awk '{print $5}'`

#Service
SERVICE=`ps -ef | grep -i 'apache-tomat\|alfesco\|php\|apache2\|mysql\|java' | awk '{print $8 $9}' | grep -v 'root' | uniq`


echo "$HOSTN;$IP/$IP2;$OS;$MANUFAC;$SERVICE;$MAXMEM;$USEDMEM;$CPUC;$CPUI;$SWAPS;$SWAPU;$TOT_DISK;$DISK" >> /script/raw.csv

#OUTPUT :-
echo -ne "\n"
echo "###################SERVER-DETAILS######################"
echo "1.  HOSTNAME = $HOSTN "
echo "2.  OPERATING SYSTEM = $OS"
echo "3.  ARCHITECTURE = $ARCH"
echo "4.  HYPERVISOR = $HTYPE"
echo "5.  MANUFACTURER = $MANUFAC"
echo "6.  PRODUCT NAME = $PRODUCTNAME"
echo "7.  CPU TYPE = $CPUI"
echo "8.  CPU USAGE = $CPU"
echo "9.  CPU OP-MODE(s) = $CPUOM"
echo "10. NO. OF CPU = $CPUC"
echo "11. NO. OF CPU SOCKETS = $CPUS"
echo "12. CPU SPEED IN MHz = $CPUMHZ"
echo "13. MAXIMUM MEMORY = $MAXMEM"
echo "14. USED MEMORY = $USEDMEM"
echo "15. PERCENTAGE MEMORY USED = $PERCENTAGE"
echo "16. SWAP DETAILS :-"
echo "       a. File System = $SWAPFS"
echo "       b. Size = $SWAPS"
echo "       c. Used = $SWAPU"
echo "       d. Priority = $SWAPP"
echo "TOTAL DISKS ATTACHED = $TOT_DISK"
echo "17. DISK DETAILS [% Usage, Total, Used, Mount] = $DISK"
echo "18. IP ADDRESS = $IP"
echo "19. SUBNET MASK = $SM"
echo "20. MAC ADDRESS = $MAC"
echo "###################SERVER-DETAILS######################"
echo "#########Top 10 Memory Usage##################################"
ps aux --sort -rss | head
echo "###########Top 10 CPU Usage##################################"
ps -e -o pcpu,pid,user,args,pmem|sort -k1 -nr|head -10
echo "###########IP TABLE Rules #####################"
iptables -L
echo "###########Partitions#####################"
df -h
echo "###########Services Status#####################"
ps -ef | grep -i 'apache-tomat\|alfesco\|php\|apache2\|mysql\|java\|puppetmaster'
#Conclusion

cd /script/
cp raw.csv raw-$(hostname).csv
sudo apt-get install sshpass
sshpass -p "BHHasd99" scp -o StrictHostKeyChecking=no raw-* sysadmin@10.10.70.142:/clients/