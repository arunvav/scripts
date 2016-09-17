#!/bin/bash
#**********Script to get Soalris Server Process Inventory************#
#*********Author : Arunvignesh.Venkatesh*******#
#****Supported OS : Solaris 8/10 Versions**#
#****Objective : Takes Inventory Report on Hardware and services Server****#
#************************************************************#

#READ ME BEFORE USE ME !!!
#The scripts you find here, are generic ones that can be applied on all the supported servers.
#Please run this script as 'root' to get exptected output.
#These script(s) have all the steps/tasks for unix/linux/solaris servers as per industry best practices, which may not be suitable for your requirement.
#So we suggest to go through the script(s) before you run and comment the tasks/steps, based on your business requirement.

rm -rf mem*
cd /inven-scripts/
export MEM_MB=$(prtconf | grep Mem | awk '{print $3}')
export MEM_GB=$(expr $MEM_MB / 1024)
echo "Total MEMORY GB : $MEM_GB"  >> mem_cpu_$(hostname)
echo "$(top | grep Memory)" >> mem_cpu_$(hostname)
echo "Total vCPUCs: $(psrinfo -v | grep Status | wc -l)" >> mem_cpu_$(hostname)
echo "##############################################################" >> mem_cpu_$(hostname)
echo "#########Core Services Usage###########" >> mem_cpu_$(hostname)
ps -ef | grep -i 'weblogic\|tomcat\|watch\|httpd\|sql\|oam' >> mem_cpu_$(hostname)
echo "#########Top 10 Memory Usage##################################" >> mem_cpu_$(hostname)
echo "PID   MEM   VSZ   RSS   COMM" >> mem_cpu_$(hostname)
ps -eo pid,pmem,vsz,rss,comm | sort -rnk2 | head >> mem_cpu_$(hostname)
echo "###########Top 10 CPU Usage##################################" >> mem_cpu_$(hostname)
echo "CPU  PID      USER         ARGS                         MEM" >> mem_cpu_$(hostname)
ps -e -o pcpu,pid,user,args,pmem|sort -k1 -nr|head -10 >> mem_cpu_$(hostname)
echo "#################DISK USAGE###########################" >> mem_cpu_$(hostname)
df -k >> mem_cpu_$(hostname)