#!/bin/bash
set -e

sed -i -e "s@AZURE_RESOURCE_GROUP@${AZURE_RESOURCE_GROUP}@g" opsmgr-pipeline/ci/azure/tasks/ansible/playbook-wipe-env.yml


cd opsmgr-pipeline/ci/azure/tasks/ansible/
 ansible-playbook  playbook-wipe-env.yml
cd ..
