#!/bin/bash
set -e

sed -i -e "s@OPSMGR_SERVER_HOSTNAME@${OPSMGR_SERVER_HOSTNAME}@g" opsmgr-pipeline/ci/azure/tasks/ansible/opsmgr-host
sed -i -e "s@AZURE_RESOURCE_LOCATION@${AZURE_RESOURCE_LOCATION}@g" opsmgr-pipeline/ci/azure/tasks/ansible/opsmgr-host
sed -i -e "s@AZURE_SERVER_ADMIN@${AZURE_SERVER_ADMIN}@g" opsmgr-pipeline/ci/azure/tasks/ansible/playbook-dataXfs.yml


# Init ssh folder and Copy ssh key file
#Get the SSH key from the configs adn add it to the ssh folder
# Add this to the config file
mkdir ~/.ssh
#Get the keys generate by previous task instead of regenerating them

cp keys-out/* ~/.ssh/

#echo -e "Host=${OPSMGR_SERVER_HOSTNAME}.${AZURE_RESOURCE_LOCATION}.cloudapp.azure.com\nIdentityFile=~/.ssh/id_rsa\nUser=${AZURE_SERVER_ADMIN}" >> ~/.ssh/config
#chmod 600 ~/.ssh/config
#chmod 600 ~/.ssh/id_rsa*




cd opsmgr-pipeline/ci/azure/tasks/ansible/
 ansible-playbook -i opsmgr-host playbook-dataXfs.yml --private-key ~/.ssh/id_rsa
cd ..
