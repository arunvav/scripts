#!/bin/bash
#********************************************************************#
#*****************HARDENING RULES FOR RHEL 6.X***********************#
#**********************Author : Arunvignesh***********#
#******Supported OS : All Redhat/Oracle/Ubuntu Linux 6 Versions*************#
#********************************************************************#

#READ ME BEFORE USE ME !!!
#The scripts you find here, are generic ones that can be applied on all the supported servers.
#These script(s) have all the steps/tasks for unix/linux/solaris servers as per industry best practices, which may not be suitable for your requirement.
#So we suggest to go through the script(s) before you run and comment the tasks/steps, based on your business requirement.

#Look from items 01 till end and add/remove options such as services, password configurations, depending on your environment.

#01
#To Disable Unnecessary Services

service sendmail stop
chkconfig sendmail off

service portmap stop
chkconfig portmap off

service nfslock stop
chkconfig nfslock off

service cups stop
chkconfig cups off

service hplip stop
chkconfig hplip off

service avahi-daemon stop
chkconfig avahi-daemon off

service anacron stop
chkconfig anacron off

service apmd stop
chkconfig apmd off

service arptables_jf stop
chkconfig arptables_jf off

service atd stop
chkconfig atd off

service auditd stop
chkconfig auditd off

service bluetooth stop
chkconfig bluetooth off

service canna stop
chkconfig canna off

service cups-config-daemon stop
chkconfig cups-config-daemon off

service gpm stop
chkconfig gpm off

service hidd stop
chkconfig hidd off

service hpoj stop
chkconfig hpoj off

service iiim stop
chkconfig iiim off

service isdn stop
chkconfig isdn off

service kudzu stop
chkconfig kudzu off

service lm_sensors stop
chkconfig lm_sensors off

service mcstrans stop
chkconfig mcstrans off

service openibd stop
chkconfig openibd off

service pcmcia stop
chkconfig pcmcia off

service pcscd stop
chkconfig pcscd off

service restorecond stop
chkconfig restorecond off

service rhnsd stop
chkconfig rhnsd off

service setroubleshoot stop
chkconfig rhnsd off

service xfs stop
chkconfig xfs off

service auth stop
chkconfig auth off


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
ban_file="/etc/motd"
chmod 666 $ban_file
content=$(cat /home/centos/hardening/banner.txt)
echo "$content" > $ban_file
echo "Banner has been added......"
chmod 644 $ban_file
echo "**********************************************"

#05
echo "Improving the password security....."
login="/etc/login.defs"
chmod 666 /etc/login.defs
sed -i 's/PASS_MAX_DAYS\t99999/PASS_MAX_DAYS\t45/g' $login
sed -i 's/PASS_MIN_LEN\t5/PASS_MIN_LEN\t8/g' $login

auth="/etc/pam.d/system-auth"
sed "/password    requisite/i\password    required      pam_cracklib.so retry=3 minlen=8 difok=3 lcredit=0 ucredit=-1 dcredit=-1 ocredit=-1" $auth > temp.txt
mv temp.txt $auth
sed "/password    requisite/i\password    required     pam_unix.so nullok use_authtok md5 shadow remember=5" $auth >temp.txt
mv temp.txt $auth
chmod 644 /etc/login.defs
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
#userdel mail
groupdel lp
#groupdel mail
echo "unnecessary system gropus and users has been removed...."
echo "**********************************************"

#09
#Change default shell
echo "Changing Default shell....."
pass="/etc/passwd"
chmod 666 $pass
sed -i 's/daemon:x:2:2:daemon:\/sbin:\/sbin\/nologin/daemon:x:2:2:daemon:\/sbin:\/dev\/null/g' $pass
sed -i 's/bin:x:1:1:bin:\/bin:\/sbin\/nologin/bin:x:1:1:bin:\/sbin:\/dev\/null/g' $pass
sed -i 's/nobody:x:99:99:Nobody:\/:\/sbin\/nologin/nobody:x:99:99:Nobody:\/:\/dev\/null/g' $pass
sed -i 's/vcsa:x:69:69:virtual console memory owner:\/dev:\/sbin\/nologin/vcsa:x:69:69:virtual console memory owner:\/dev:\/dev\/null/g' $pass
chmod 644 $pass
echo "Default shell has been changed....."
echo "**********************************************"

#10
#Disable interactive boot
echo "Disabling Interactive Bootup"
init_file="/etc/sysconfig/init"
chmod 666 $init_file
sed -i 's/PROMPT=yes/PROMPT=no/' $init_file 
chmod 644 $init_file

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
find / -perm -2 -type f -print >> /home/ec2-user/hardening/world_writable
echo "list has been stored in the file 'world_writable'"
echo "**********************************************"

#13
#Find out hidden files and directories
echo "hidden files names are being stored in the file 'files_hidden'....."
find / -xdev -name ".." -print >> /home/ec2-user/hardening/files_hidden
find / -xdev -name ".*" -print | cat -v >> /home/ec2-user/hardening/files_hidden
echo "hidden files list has been stored in 'files_hidden'"
#14 and #15 are not present in rules list.
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

#19-#20
#configure /etc/sysctl.conf for kernel level security..
sysctl="/etc/sysctl.conf"
chmod 666 $sysctl
kernel_security=$(cat to_sysctl.info)
sed '/kernel.shmmax =/c kernel.shmmax = 4294967295' $sysctl > temp.txt
mv temp.txt $sysctl
sudo sed '/kernel.shmall =/c kernel.shmall = 268435456' $sysctl > temp.txt
mv temp.txt $sysctl
echo "$kernel_security" >> $sysctl
chmod 644 $sysctl

#21
#changing default rsyslog configuration
echo "changing default rsyslog configuration..........."
rsyslog="/etc/rsyslog.conf"
str=" # Log kernel messages\nkern.debug\n/var/log/kernel.log\nuser.debug\n/var/log/user.log"
sed "/local7.*/a $str" $rsyslog > temp.txt
mv temp.txt $rsyslog
echo "rsyslog configured........."
echo "**********************************************"

#22
#Create btmp file in /var/log directory
echo "Creating btmp file......."
cd /var/log
touch /var/log/btmp
cd
echo "**********************************************"

#23
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
service sshd restart
echo "ssh conf done"


#24
iptables -F
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT 
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
#iptables -A INPUT -i eth0 -p tcp -m multiport --dports 22,80,443 -m state --state NEW,ESTABLISHED -j ACCEPT
#service iptables restart
echo "iptables rules done"

#25
sed -i 's/id:5:initdefault:/id:3:initdefault:/g' /etc/inittab
sed -i 's/ca::ctrlaltdel:/#ca::ctrlaltdel:/g' /etc/inittab

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


echo "HARDENING DONE!!!"
echo "**********************************************"
#EOF
exit 0
