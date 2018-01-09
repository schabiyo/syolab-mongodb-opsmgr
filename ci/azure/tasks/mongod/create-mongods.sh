#!/bin/bash
set -e

#touch opsmgr-pipeline/ci/azure/tasks/ansible/mongod-hosts
#printf "%s\n" "[dockerhosts]" >> opsmgr-pipeline/ci/azure/tasks/ansible/mongods-hosts
#printf "%s\n" "${OPSMGR_SERVER_HOSTNAME}.${AZURE_RESOURCE_LOCATION}.cloudapp.azure.com" >> opsmgr-pipeline/ci/azure/tasks/ansible/mongod-hosts

sed -i -e "s@AZURE_SERVER_ADMIN@${AZURE_SERVER_ADMIN}@g" opsmgr-pipeline/ci/azure/tasks/mongod/ansible/playbook-create-mongods.yml
sed -i -e "s@AZURE_RESOURCE_LOCATION@${AZURE_RESOURCE_LOCATION}@g" opsmgr-pipeline/ci/azure/tasks/mongod/ansible/playbook-create-mongods.yml
sed -i -e "s@AZURE_RESOURCE_GROUP@${AZURE_RESOURCE_GROUP}@g" opsmgr-pipeline/ci/azure/tasks/mongod/ansible/playbook-create-mongods.yml
sed -i -e "s@OPSMGR_SERVER_HOSTNAME@${OPSMGR_SERVER_HOSTNAME}@g" opsmgr-pipeline/ci/azure/tasks/mongod/ansible/playbook-create-mongods.yml
sed -i -e "s~MONGOD_SSHKEY_PUBLIC~${MONGOD_SSHKEY_PUBLIC}~g" opsmgr-pipeline/ci/azure/tasks/mongod/ansible/playbook-create-mongods.yml
sed -i -e "s@AZURE_SERVER_ADMIN@${AZURE_SERVER_ADMIN}@g" opsmgr-pipeline/ci/azure/tasks/mongod/ansible/playbook-create-mongods.yml
sed -i -e "s@OPSMGR_DATA_DISK_SIZE@${OPSMGR_DATA_DISK_SIZE}@g" opsmgr-pipeline/ci/azure/tasks/mongod/ansible/playbook-create-mongods.yml
sed -i -e "s@MONGOD_DATA_DISK_TYPE@${MONGOD_DATA_DISK_TYPE}@g" opsmgr-pipeline/ci/azure/tasks/mongod/ansible/playbook-create-mongods.yml


# Init ssh folder and Copy ssh key file
#Get the SSH key from the configs adn add it to the ssh folder
mkdir ~/.ssh


#Had to do this as the key is being read in one single line
printf "%s\n" "-----BEGIN RSA PRIVATE KEY-----" >> ~/.ssh/id_rsa
printf "%s\n" $MONGOD_SSHKEY_PRIVATE | tail -n +5 | head -n -4 >>  ~/.ssh/id_rsa
printf "%s" "-----END RSA PRIVATE KEY-----" >> ~/.ssh/id_rsa


echo $MONGOD_SSHKEY_PUBLIC >> ~/.ssh/id_rsa.pub
# Add this to the config file
# echo -e "Host=${OPSMGR_SERVER_HOSTNAME}.${AZURE_RESOURCE_LOCATION}.cloudapp.azure.com\nIdentityFile=~/.ssh/id_rsa\nUser=${AZURE_SERVER_ADMIN}" >> ~/.ssh/config
# chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_rsa*

# Make the keys availanle for future tasks
cp ~/.ssh/* keys-out/


cd opsmgr-pipeline/ci/azure/tasks/mongod/ansible
 ansible-playbook playbook-create-mongods.yml --private-key ~/.ssh/id_rsa
cd ..
