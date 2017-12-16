#!/bin/bash
set -e

sed -i -e "s@OPSMGR_SERVER_HOSTNAME@${OPSMGR_SERVER_HOSTNAME}@g" opsmgr-pipeline/ci/azure/tasks/ansible/opsmgr-host
sed -i -e "s@AZURE_RESOURCE_LOCATION@${AZURE_RESOURCE_LOCATION}@g" opsmgr-pipeline/ci/azure/tasks/ansible/opsmgr-host
sed -i -e "s@AZURE_SERVER_ADMIN@${AZURE_SERVER_ADMIN}@g" opsmgr-pipeline/ci/azure/tasks/ansible/playbook-install-mongods.yml


# Init ssh folder and Copy ssh key file
#Get the SSH key from the configs adn add it to the ssh folder
mkdir ~/.ssh
#Get the keys generate by previous task instead of regenerating them

cp keys-out/* ~/.ssh/

cd opsmgr-pipeline/ci/azure/tasks/ansible/
 ansible-playbook -i opsmgr-host playbook-install-mongods.yml --private-key ~/.ssh/id_rsa
cd ..
