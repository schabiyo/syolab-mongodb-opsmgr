#!/bin/bash
set -e

sed -i -e "s@AZURE_RESOURCE_GROUP@${AZURE_RESOURCE_GROUP}@g" opsmgr-pipeline/ci/azure/tasks/mongod/ansible/playbook-wipe-mongods-env.yml


cd opsmgr-pipeline/ci/azure/tasks/mongod/ansible/
 ansible-playbook  playbook-wipe-mongods-env.yml
cd ..
