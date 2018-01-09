#!/bin/bash
set -e

touch opsmgr-pipeline/ci/azure/tasks/ansible/hosts
printf "%s\n" "[opsManager]" >> opsmgr-pipeline/ci/azure/tasks/ansible/hosts
printf "%s\n" "${OPSMGR_SERVER_HOSTNAME}.${AZURE_RESOURCE_LOCATION}.cloudapp.azure.com" >> opsmgr-pipeline/ci/azure/tasks/ansible/hosts

printf "%s\n" "[mongoDs]" >> opsmgr-pipeline/ci/azure/tasks/ansible/hosts

for (( i=1; i<"${NB_NODES}" ; i++ )) ; do
  printf "%s\n" "${MONGOD_SERVER_PREFIX}${i}.${AZURE_RESOURCE_LOCATION}.cloudapp.azure.com" >> opsmgr-pipeline/ci/azure/tasks/ansible/hosts
done


sed -i -e "s@AZURE_SERVER_ADMIN@${AZURE_SERVER_ADMIN}@g" opsmgr-pipeline/ci/azure/tasks/mongod/playbook-automation-agent.yml
sed -i -e "s@AZURE_RESOURCE_LOCATION@${AZURE_RESOURCE_LOCATION}@g" opsmgr-pipeline/ci/azure/tasks/mongod/playbook-automation-agent.yml
sed -i -e "s@OPSMGR_URL@${OPSMGR_CENTRAL_URL}:8080@g" opsmgr-pipeline/ci/azure/tasks/mongod/playbook-automation-agent.yml
sed -i -e "s@OPSMGR_SERVER_HOSTNAME@${OPSMGR_SERVER_HOSTNAME}@g" opsmgr-pipeline/ci/azure/tasks/mongod/playbook-automation-agent.yml

# Init ssh folder and Copy ssh key file
#Get the SSH key from the configs adn add it to the ssh folder
mkdir ~/.ssh


#Had to do this as the key is being read in one single line
printf "%s\n" "-----BEGIN RSA PRIVATE KEY-----" >> ~/.ssh/id_rsa
printf "%s\n" $MONGOD_SSHKEY_PRIVATE | tail -n +5 | head -n -4 >>  ~/.ssh/id_rsa
printf "%s" "-----END RSA PRIVATE KEY-----" >> ~/.ssh/id_rsa


echo $MONGOD_SSHKEY_PUBLIC >> ~/.ssh/id_rsa.pub
# Add this to the config file
echo -e "Host=${OPSMGR_SERVER_HOSTNAME}.${AZURE_RESOURCE_LOCATION}.cloudapp.azure.com\nIdentityFile=~/.ssh/id_rsa\nUser=${AZURE_SERVER_ADMIN}" >> ~/.ssh/config
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_rsa*

# Make the keys availanle for future tasks
cp ~/.ssh/* keys-out/


cd opsmgr-pipeline/ci/azure/tasks/mongod/
 ansible-playbook -i hosts playbook-automation-agent.yml --private-key ~/.ssh/id_rsa
cd ..
