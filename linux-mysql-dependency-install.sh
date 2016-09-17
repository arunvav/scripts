#!/bin/bash
#**********Script to get Linux Server Inventory************#
#*********Author : Arunvignesh.Venkatesh*******#
#****Supported OS : All Redhat/Oracle Linux Versions**#
#***Install mysql server community edition with its dependencies****#
#************************************************************#

#READ ME BEFORE USE ME !!!
#The scripts you find here, are generic ones that can be applied on all the supported servers.
#These script(s) have all the steps/tasks for unix/linux/solaris servers as per industry best practices, which may not be suitable for your requirement.
#So we suggest to go through the script(s) before you run and comment the tasks/steps, based on your business requirement.

#Change Required : systemctl command needs to be changed for Linux 6 flavours.

yum -y install wget
echo "wget installed"
yum -y install telnet
echo "telnet installed"
wget http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
rpm -Uvh mysql-community-release-el7-5.noarch.rpm
yum -y install mysql-community-server
systemctl start mysqld
systemctl enable mysqld

#changing above 2 options to service mysqld start, service enable mysql, shall run this script on Linux 6 versions.

echo "MYSQL DB Installed"
mkdir /mysql-data
echo "/mysql-data created"