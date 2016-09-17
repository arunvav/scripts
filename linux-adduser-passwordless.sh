#!/bin/bash
#********************************************************************#
#**********Script to add a user to Linux system - PASSWORD LESS - KEY BASE Authendication - Intearctive**********#
#**********************Author : Arunvignesh***********#
#******Supported OS : All Redhat/Oracle/Ubuntu Linux Versions*************#
#********************************************************************#

#READ ME BEFORE USE ME !!!
#The scripts you find here, are generic ones that can be applied on all the supported servers.
#Please run this as ‘root’ to get expected output.
#These script(s) have all the steps/tasks for unix/linux/solaris servers as per industry best practices, which may not be suitable for your requirement.
#So we suggest to go through the script(s) before you run and comment the tasks/steps, based on your business requirement.

#Change Required : Make sure to change password & Root authendication mode to no in SSH conf
#Change Required : Make sure to change user name from ec2-user to valid user name.


sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

if [ $(id -u) -eq 0 ]; then
        read -p "Enter username : " username
        read -s -p "Enter password : " password
        egrep "^$username" /etc/passwd >/dev/null
        if [ $? -eq 0 ]; then
                echo "$username exists!"
                exit 1
        else
                pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
                useradd -m -p $pass $username
                [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
        cd /home/ec2-user/
        cp -r .ssh/ /home/$username/
        chown $username:$username /home/$username/.ssh/
        chown $username:$username /home/$username/.ssh/authorized_keys
        chmod 600 /home/$username/.ssh/authorized_keys
        echo "auth key copied under" $username "home dir"
        fi
else
        echo "Only root may add a user to the system"
        exit 2
fi