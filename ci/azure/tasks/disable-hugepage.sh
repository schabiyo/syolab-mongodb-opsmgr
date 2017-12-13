#!/bin/bash
set -e

touch opsmgr-pipeline/ci/azure/tasks/ansible/opsmgr-host
printf "%s\n" "[OpsManager]" >> opsmgr-pipeline/ci/azure/tasks/ansible/opsmgr-host
printf "%s\n" "${OPSMGR_SERVER_HOSTNAME}.${AZURE_RESOURCE_LOCATION}.cloudapp.azure.com" >> opsmgr-pipeline/ci/azure/tasks/ansible/opsgmr-host

sed -i -e "s@AZURE_SERVER_ADMIN@${AZURE_SERVER_ADMIN}@g" opsmgr-pipeline/ci/azure/tasks/ansible/playbook-disable-hugepage.yml


#Get the SSH key from the configs adn add it to the ssh folder
mkdir ~/.ssh
#Get the keys generate by previous task instead of regenerating them
cp keys-out/* ~/.ssh/

cd opsmgr-pipeline/ci/azure/tasks/ansible/
 ansible-playbook -i opsmgr-host playbook-hugepage.yml --private-key ~/.ssh/id_rsa
cd ..
