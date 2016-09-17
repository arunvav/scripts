#!/bin/bash
#********************************************************************#
#**********Script to check Weblogic Container's usage - Comsumption, Peering IPs **********#
#*********Author : Arunvignesh.Venkatesh*******#
#******Supported OS : Solaris 8.X/9.X/10.X **************#
#********************************************************************#

#READ ME BEFORE USE ME !!!
#The scripts you find here, are generic ones that can be applied on all the supported servers.
# Please run this as root to get expected results.
#These script(s) have all the steps/tasks for unix/linux/solaris servers as per industry best practices, which may not be suitable for your requirement.
#So we suggest to go through the script(s) before you run and comment the tasks/steps, based on your business requirement.

#Change Required : NA

mkdir /inven-scripts/
cd /inven-scripts/
rm -rf file*
echo "#########################################"
ps -ef | grep -i weblogic.Name  | awk '{print $2, $10, $11, $12}' >> file_containers_pids
cat file_containers_pids | awk '{print $1}' >> file_pids
echo $(hostname) >> file_pid_mem;
echo $(date) >> file_pid_mem;
for i in $(cat file_pids);
do
pmap -x $i | grep total | awk '{print $3}';
export PMEM=$(pmap -x $i | grep total | awk '{print $3}');
export PMEM_MB=$(expr $PMEM / 1024);
export PPROC_NAME=$(cat file_containers_pids | grep $i | awk '{print $2}');
echo "MEMORY : $PMEM_MB, PID : $i, CONTAINER NAME : $PPROC_NAME" >> file_pid_mem;
export PPORT=$(pfiles $i | grep -i AF_INET);
echo "For PID : $i - PROCESS : $PPROC_NAME - PORTs : $PPORT" >> file_pid_mem;
done
mv file_pids file_pids-$(date +%Y-%m-%d-%T)
mv file_containers_pids file_containers_pids-$(date +%Y-%m-%d-%T)
mv file_pid_mem file_pid_mem-$(date +%Y-%m-%d-%T)