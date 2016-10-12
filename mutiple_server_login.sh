for HOST in $(cat servers); 
do 

sshpass -p "BHHasd99" ssh -o StrictHostKeyChecking=no sysadmin@$HOST "sudo mkdir /script/; sudo chmod 777 /script/; sudo chmod +t /script/";

sshpass -p "BHHasd99" scp -o StrictHostKeyChecking=no inventory.sh sysadmin@$HOST:/script/;

sshpass -p "BHHasd99" ssh -o StrictHostKeyChecking=no sysadmin@$HOST "sudo sh /script/inventory.sh >> /script/output-$HOST;";

sshpass -p "BHHasd99" scp -o StrictHostKeyChecking=no sysadmin@$HOST:/script/output-* /clients/

done
