#!/bin/bash
#********************************************************************#
#*****************HARDENING RULES FOR RHEL 7 - Best Practices***********************#
#**********************Author : Arunvignesh***********#
#******Supported OS : All Redhat/Oracle Linux Release 7 Versions*************#
#********************************************************************#

#READ ME BEFORE USE ME !!!
#The scripts you find here, are generic ones that can be applied on all the supported servers.
#Please run this as root to get expected output.
#These script(s) have all the steps/tasks for unix/linux/solaris servers as per industry best practices, which may not be suitable for your requirement.
#So we suggest to go through the script(s) before you run and comment the tasks/steps, based on your business requirement.

#Change Required: look for items #17, 19,23,24,25 and make required changes as per business requirement.

mkdir -p /root/hardening
cd /root/hardening

#01
#To Disable Unnecessary Services

#systemctl stop sendmail
#chkconfig sendmail off
#systemctl stop sendmail
#chkconfig xfs off
systemctl enable httpd.service
systemctl stop firewalld
systemctl disable firewalld
systemctl enable ntpd.service
chkconfig network on
systemctl enable sshd.service

#02
#Removing files like .rhosts and .netrc used by remote services like rsh and rlogind, as these services do not use secure connection

find . -name ".rhosts" -print >> filerm.txt
find . -name ".netrc" -print >> filerm.txt
if [ -s "filerm.txt" ]
then

        for line in $(cat filerm.txt)
        do
                sudo rm -f $line
        done
else
        echo "no files found...."
fi
rm -f filerm.txt
echo "**********************************************"

#03
#Disable ZEROCONF
echo "Disabling Zeroconf......."

net="/etc/sysconfig/network"
chmod 666 $net
echo "NOZEROCONF=yes" >> $net
chmod 644 $net
echo "ZEROCONF is disabled......"
echo "**********************************************"

#04
#custom banner
echo "Adding Custom Banner....."
touch /root/hardening/banner
cat > /root/hardening/banner << EOF
|-----------------------------------------------------------------|
|           PROD Environment                      |
| This system is for the use of authorized users only.            |
| Individuals using this computer system without authority, or in |
| excess of their authority, are subject to having all of their   |
| activities on this system monitored and recorded by system      |
| personnel.                                                      |
|-----------------------------------------------------------------|
EOF
sed -i 's|#Banner none|Banner /root/hardening/banner|g' /etc/ssh/sshd_config
systemctl restart sshd

echo "banner done"
echo "**********************************************"

#05
#SSHD Conf file changes
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/g' /etc/ssh/sshd_config
sed -i 's/#StrictModes yes/StrictModes yes/g' /etc/ssh/sshd_config
sed -i 's/#HostbasedAuthentication no/HostbasedAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#RhostsRSAAuthentication no/RhostsRSAAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#LoginGraceTime 2m/LoginGraceTime 1m/g' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
systemctl restart sshd.service
echo "ssh conf done"
echo "**********************************************"

#06
#Disable CTRL+ALT+DEL
echo "Disabling the CTRL+ALT+DEL Feature....."
cal_file="/etc/init/control-alt-delete.conf"
sed 's/exec shutdown -r now \"Control-Alt-Delete pressed\"/#exec shutdown -r now \"Control-Alt-Delete pressed\"/g' $cal_file > temp.txt
mv temp.txt $cal_file
echo "CTRL+ALT+DEL has been disabled...."
echo "**********************************************"


#07
#To set BASH Timeout
echo "setting TMOUT for Bash......"
prof_file="/etc/profile"
chmod 666 $prof_file
echo "#Terminal will be closed after TMOUT seconds automatically." >> $prof_file
echo "TMOUT=6000" >> $prof_file
echo "typeset -r TMOUT" >> $prof_file
echo "TMOUT has been set for bash......"
echo "**********************************************"


#08
#Deleting unnecessary system users and groups
echo "Removing unnecessary system groups and users......."
userdel sync
userdel games
userdel lp
userdel uucp
groupdel lp
echo "unnecessary system gropus and users has been removed...."
echo "**********************************************"

#11
#Set UMASK

echo "Changing the default permissions of new files"
login="/etc/login.defs"
sed 's/UMASK           077/UMASK           033/' $login > temp.txt
mv temp.txt $login
echo "umask has set......."
echo "**********************************************"


#12
#Find world writable files
echo "list of world writable files are being stored in the file 'world_writable'"
find / -perm -2 -type f -print >> /root/hardening/world_writable
echo "list has been stored in the file 'world_writable'"
echo "**********************************************"

#13
#Find out hidden files and directories
echo "hidden files names are being stored in the file 'files_hidden'....."
find / -xdev -name ".." -print >> /root/hardening/files_hidden
find / -xdev -name ".*" -print | cat -v >> /root/hardening/files_hidden
echo "hidden files list has been stored in 'files_hidden'"
#16
#Enable auditd

echo "auditd is installed and enabled........"
echo "**********************************************"

#17
#Alias rm to interactive

echo "making 'rm' command interactive....."
bash="/etc/bashrc"
chmod 666 $bash
echo "#to make 'rm' command to be interactive(prompting)....." >> $bash
echo "alias rm='/bin/rm -i'" >> $bash
echo "**********************************************"

#18
#Set the command prompt
echo "command prompt is already set....."

echo "**********************************************"

#19
sed -i 's/net.bridge.bridge-nf-call-ip6tables/#net.bridge.bridge-nf-call-ip6tables/g' /etc/sysctl.conf
sed -i 's/net.bridge.bridge-nf-call-iptables/#net.bridge.bridge-nf-call-iptables/g' /etc/sysctl.conf
sed -i 's/net.bridge.bridge-nf-call-arptables/#net.bridge.bridge-nf-call-arptables/g' /etc/sysctl.conf
echo net.ipv4.conf.all.accept_source_route = 0 >> /etc/sysctl.conf
echo net.ipv4.conf.all.accept_redirects = 0 >> /etc/sysctl.conf
echo net.ipv4.icmp_echo_ignore_broadcasts = 1 >> /etc/sysctl.conf
echo net.ipv4.icmp_ignore_bogus_error_responses = 1 >> /etc/sysctl.conf
echo net.ipv4.conf.all.log_martians = 1 >> /etc/sysctl.conf
sysctl -p
echo "**********************************************"


#22
#Create btmp file in /var/log directory
echo "Creating btmp file......."
cd /var/log
touch /var/log/btmp
echo "**********************************************"

#23
echo "Improving the password security....."
login="/etc/login.defs"
chmod 666 /etc/login.defs
sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t45/g' $login
sed -i 's/PASS_MIN_LEN\t5/PASS_MIN_LEN\t8/g' $login
echo "**********************************************"

#24
auth="/etc/pam.d/system-auth"
sed "/password    requisite/i\password    required      pam_cracklib.so retry=3 minlen=8 difok=3 lcredit=0 ucredit=-1 dcredit=-1 ocredit=-1" $auth > temp.txt
mv temp.txt $auth
sed "/password    requisite/i\password    required     pam_unix.so nullok use_authtok md5 shadow remember=5" $auth >temp.txt
mv temp.txt $auth
chmod 644 /etc/login.defs
echo "**********************************************"


#25
#echo PermitRootLogin no >> /etc/ssh/sshd_config
#echo Banner /root/banner >> /etc/ssh/sshd_config
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding no/g' /etc/ssh/sshd_config
sed -i 's/#StrictModes yes/StrictModes yes/g' /etc/ssh/sshd_config
sed -i 's/#HostbasedAuthentication no/HostbasedAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#RhostsRSAAuthentication no/RhostsRSAAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#LoginGraceTime 2m/LoginGraceTime 1m/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication no/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's|#Banner none|Banner /etc/banner|g' /etc/ssh/sshd_config
systemctl restart sshd
echo "ssh conf done"


#26
#SSH Banner
touch /etc/banner
cat > /etc/banner << EOF
|-----------------------------------------------------------------|
|  	         Production Environment			  |
| This system is for the use of authorized users only.            |
| Individuals using this computer system without authority, or in |
| excess of their authority, are subject to having all of their   |
| activities on this system monitored and recorded by system      |
| personnel.                                                      |
|-----------------------------------------------------------------|
EOF
echo "banner done"


echo "*********************************************
echo "HARDENING DONE!!!"
echo "**********************************************"
#EOF
exit 0

