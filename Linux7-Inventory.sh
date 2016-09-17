#!/bin/bash
#**********Script to get Linux Server Inventory such as Disk Space, Memory Utilization************#
#*********Author : Arunvignesh.Venkatesh*******#
#****Supported OS : All Redhat/Oracle/Ubuntu Linux Versions**#
#************************************************************#

#READ ME BEFORE USE ME !!!
#The scripts you find here, are generic ones that can be applied on all the supported servers.
#Please run this as ‘root’ to get expected output.
#These script(s) have all the steps/tasks for unix/linux/solaris servers as per industry best practices, which may not be suitable for your requirement.
#So we suggest to go through the script(s) before you run and comment the tasks/steps, based on your business requirement.

#Change Required: Check df -H as output of ‘/’ partition may skip a line – resulting different output. 

#HOSTNAME :-
HOSTN=`/bin/hostname`
#OPERATING SYSTEM :-
OS=`cat /etc/redhat-release`
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
MANUFAC=`/usr/sbin/dmidecode --type system | grep Manufacturer | cut -d ":" -f2`

#PRODUCT NAME :-
PRODUCTNAME=`/usr/sbin/dmidecode | grep "Product Name: V" | cut -d ":" -f2 | awk '$1=$1'`

#CPU Info/Type
CPUI=`cat /proc/cpuinfo | grep "model name" | cut -d ":" -f2`

#CPU Usage
CPU=`top -b -n1 | grep "Cpu(s)" | awk '{print $2 + $4}'`

#CPU Details
CPUOM=`/usr/bin/lscpu | grep "CPU op" | cut -d ":" -f2 | awk '$1=$1'`
CPUC=`/usr/bin/lscpu | grep -i "CPU(s):" | cut -d ":" -f2 | awk '$1=$1'`
CPUS=`/usr/bin/lscpu | grep -i "CPU socket(s)" | cut -d ":" -f2 | awk '$1=$1'`
CPUMHZ=`/usr/bin/lscpu | grep -i "CPU MHz" | cut -d ":" -f2 | awk '$1=$1'`

#MEMORY DETAILS
MEMUSAGE=`top -n 1 -b | grep "KiB Mem"`
MAXMEM1=`echo $MEMUSAGE | cut -d" " -f2 | awk '{print substr($0,1,length($0)-1)}'`
MAXMEM=$(expr $MAXMEM1 / 1024)
USEDMEM2=`echo $MEMUSAGE | cut -d" " -f4 | awk '{print substr($0,1,length($0)-1)}'`
USEDMEM=$(expr $USEDMEM2 / 1024)
USEDMEM1=`expr $USEDMEM \* 100`
PERCENTAGE=`expr $USEDMEM1 / $MAXMEM`

#SWAP DETAILS
SWAPFS=`swapon -s | grep -vE '^Filename' | awk '{ printf $1}'`
SWAPS1=`swapon -s | grep -vE '^Filename' | awk '{ printf $3}'`
SWAPS=$(expr $SWAPS1 / 1024)
SWAPU1=`swapon -s | grep -vE '^Filename' | awk '{ printf $4}'`
SWAPU=$(expr $SWAPU1 / 1024)
SWAPP1=`swapon -s | grep -vE '^Filename' | awk '{ printf $5}'`
SWAPP=$(expr $SWAPP1 / 1024)

#DISK
DISK=`df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ printf $5 " " $1" | "}'`

#NETWORK DETAILS
IP=`ifconfig eth0 | grep "inet addr" | cut -d ":" -f2 | awk '{printf $1}'`
SM=`ifconfig eth0 | grep "inet addr" | cut -d ":" -f4`
MAC=`cat /etc/sysconfig/network-scripts/ifcfg-eth[0123] | grep -i HWADDR | cut -d "=" -f2`

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
echo "13. MAXIMUM MEMORY (MB) = $MAXMEM"
echo "14. USED MEMORY (MB)= $USEDMEM"
echo "15. PERCENTAGE MEMORY USED = $PERCENTAGE"
echo "16. SWAP DETAILS :-"
echo "       a. File System = $SWAPFS"
echo "       b. Size (MB)= $SWAPS"
echo "       c. Used (MB)= $SWAPU"
echo "       d. Priority = $SWAPP"
echo "17. DISK DETAILS [% Usage, FileSystem] = $DISK"
echo "18. IP ADDRESS = $IP"
echo "19. SUBNET MASK = $SM"
echo "20. MAC ADDRESS = $MAC"
echo "###################SERVER-DETAILS######################"
echo -ne "\n"
echo "#########Top 10 Memory Usage##################################"
ps aux --sort -rss | head
echo "###########Top 10 CPU Usage##################################"
ps -e -o pcpu,pid,user,args,pmem|sort -k1 -nr|head -10
#Conclusion