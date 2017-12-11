#!/bin/bash
set -e

printf "%s\n" "[dockerhosts]" >> mongodb-pipeline/ci/azure/tasks/ansible/opsmgr-host
printf "%s\n" "${OPSMGR_SERVER_HOSTNAME}.${AZURE_RESOURCE_LOCATION}.cloudapp.azure.com" >> mongodb-azure-scripts/ci/azure/tasks/ansible/opsgmr-host

sed -i -e "s@AZURE_SERVER_ADMIN@${AZURE_SERVER_ADMIN}@g" mongodb-pipeline/ci/azure/tasks/ansible/playbook-create-opsmgr-vm.yml
sed -i -e "s@AZURE_RESOURCE_LOCATION@${AZURE_RESOURCE_LOCATION}@g" mongodb-pipeline/ci/azure/tasks/ansible/playbook-create-opsmgr-vm.yml
sed -i -e "s@AZURE_RESOURCE_GROUP@${AZURE_RESOURCE_GROUP}@g" mongodb-pipeline/ci/azure/tasks/ansible/playbook-create-opsmgr-vm.yml
sed -i -e "s@OPSMGR_SSHKEY_PUBLIC@${AZURE_RESOURCE_GROUP}@g" mongodb-pipeline/ci/azure/tasks/ansible/playbook-create-opsmgr-vm.yml
sed -i -e "s@AZURE_SERVER_ADMIN_USER@${AZURE_SERVER_ADMIN}@g" mongodb-pipeline/ci/azure/tasks/ansible/playbook-create-opsmgr-vm.yml
sed -i -e "s@OPSMGR_SERVER_HOSTNAME@dev-${OPSMGR_SERVER_HOSTNAME}@g" mongodb-pipeline/ci/azure/tasks/ansible/playbook-create-opsmgr-vm.yml


# Init ssh folder and Copy ssh key file
#Get the SSH key from the configs adn add it to the ssh folder
mkdir ~/.ssh


#Had to do this as the key is being read in one single line
printf "%s\n" "-----BEGIN RSA PRIVATE KEY-----" >> ~/.ssh/id_rsa
printf "%s\n" $OPSMGR_SSHKEY_PRIVATE | tail -n +5 | head -n -4 >>  ~/.ssh/id_rsa
printf "%s" "-----END RSA PRIVATE KEY-----" >> ~/.ssh/id_rsa


echo $OPSMGR_SSHKEY_PUBLIC >> ~/.ssh/id_rsa.pub
# Add this to the config file
echo -e "Host=dev-${OPSMGR_SERVER_HOSTNAME}.${AZURE_RESOURCE_LOCATION}.cloudapp.azure.com\nIdentityFile=~/.ssh/id_rsa\nUser=${AZURE_SERVER_ADMIN}" >> ~/.ssh/config
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_rsa*




cd mongodb-pipeline/ci/azure/tasks/ansible/
 ansible-playbook -i opsmgr-host playbook-create-opsmgr-vm.yml --private-key ~/.ssh/id_rsa
cd ..
