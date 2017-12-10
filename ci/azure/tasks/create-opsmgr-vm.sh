#!/bin/bash
set -e

printf "%s\n" "[dockerhosts]" >> mongodb-pipeline/ci/azure/tasks/ansible/opsmgr-host
printf "%s\n" "${AZURE_SERVER_PREFIX}.${AZURE_RESOURCE_LOCATION}.cloudapp.azure.com" >> mongodb-azure-scripts/ci/azure/tasks/ansible/opsgmr-host

sed -i -e "s@AZURE_SERVER_ADMIN@${AZURE_SERVER_ADMIN}@g" mongodb-pipeline/ci/azure/tasks/ansible/playbook-create-opsmgr-vm.yml
sed -i -e "s@AZURE_RESOURCE_LOCATION@${AZURE_RESOURCE_LOCATION}@g" mongodb-pipeline/ci/azure/tasks/ansible/playbook-create-opsmgr-vm.yml
sed -i -e "s@AZURE_RESOURCE_GROUP@${AZURE_RESOURCE_GROUP}@g" mongodb-pipeline/ci/azure/tasks/ansible/playbook-create-opsmgr-vm.yml
sed -i -e "s@DOCKER-HOSTNAME@dev-${AZURE_SERVER_PREFIX}@g" mongodb-pipeline/ci/azure/tasks/ansible/playbook-create-opsmgr-vm.yml

cd mongodb-pipeline/ci/azure/tasks/ansible/
 ansible-playbook -i opsmgr-host playbook-create-opsmgr-vm.yml --private-key ~/.ssh/${server_prefix}_id_rsa
cd ..
