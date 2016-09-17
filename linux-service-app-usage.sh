#!/bin/bash
#********************************************************************#
#**********Script to check service / app's usage - memory utilization, Peering connection Intearctive**********#
#**********************Author : Arunvignesh***********#
#******Supported OS : All Redhat/Oracle/Ubuntu Linux Versions*************#
#******Objective : Checks the Memory Usage, Peerign IPs, PIDs of services such as mysql, weblgoic, apache *************#
#********************************************************************#

#READ ME BEFORE USE ME !!!
#The scripts you find here, are generic ones that can be applied on all the supported servers.
#Please run this as root to get expeted output.
#These script(s) have all the steps/tasks for unix/linux/solaris servers as per industry best practices, which may not be suitable for your requirement.
#So we suggest to go through the script(s) before you run and comment the tasks/steps, based on your business requirement.

#Edit or remove services in below ps cmd based on your server environment.

mkdir /inven-scripts/
cd /inven-scripts/
rm -rf rhfile*
echo "#########################################"
ps -ef | grep -i 'weblogic.Name\|mysql\|console\|warehouse\|oracle\|sunone\|httpd\|informatica' | awk '{print $2, $8, $10, $11, $12}' >> rhfile_service_pids;
cat rhfile_service_pids | awk '{print $1}' >> rhfile_pids;
echo $(hostname) >> rhfile_pid_mem;
echo $(date) >> rhfile_pid_mem;
for i in $(cat rhfile_pids)
do
pmap -x $i | grep total | awk '{print $3}'
export PMEM=$(pmap -x $i | grep total | awk '{print $3}')
export PMEM_MB=($PMEM / 1024);
export PPROC_NAME=$(cat rhfile_service_pids | grep $i | awk '{print $2}')
echo "MEMORY : $PMEM_MB, PID : $i, SERVICE NAME : $PPROC_NAME" >> rhfile_pid_mem
export PPORT=$(netstat -anop | grep $i)
echo "For PID : $i - PROCESS : $PPROC_NAME - PORTs : $PPORT" >> rhfile_pid_mem
done
cp rhfile_pid_mem rhfile_pid_mem-$(hostname)