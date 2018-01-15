#!/bin/bash
set -e

sed -i -e "s@OPSMGR_SERVER_HOSTNAME@${OPSMGR_SERVER_HOSTNAME}@g" opsmgr-pipeline/ci/azure/tasks/ansible/opsmgr-host
sed -i -e "s@AZURE_RESOURCE_LOCATION@${AZURE_RESOURCE_LOCATION}@g" opsmgr-pipeline/ci/azure/tasks/ansible/opsmgr-host

az login --service-principal -u "$AZURE_CLIENT_ID" -p "$AZURE_SECRET" --tenant "$AZURE_TENANT" &> /dev/null
az account set --subscription "$AZURE_SUBSCRIPTION_ID"  &> /dev/null

COMMAND="az storage account  keys list --resource-group AZURE_RESOURCE_LOCATION --account-name STORAGE_ACCOUNT_NAME"

NEW_COMMAND=$(sed  "s@AZURE_RESOURCE_LOCATION@${AZURE_RESOURCE_LOCATION}@g" <<< $COMMAND)
NEW_COMMAND=$(sed  "s@STORAGE_ACCOUNT_NAME@${STORAGE_ACCOUNT_NAME}@g" <<< $NEW_COMMAND)

#Check if we got a 200 back
result=$(eval curl $NEW_COMMAND)
if [[ $result == *"error"* ]]; then
  echo $result
  exit 1
else
    #Get the state
    key=$(jq .value <<< $result)
    TRIMMED_RESULT="${key%\"}"
    TRIMMED_RESULT="${TRIMMED_RESULT#\"}"
    eval $responsevar="'$TRIMMED_RESULT'"
    sed -i -e "s@STORAGEACCOUNT_SECRET_KEY@${TRIMMED_RESULT}@g" opsmgr-pipeline/ci/azure/tasks/ansible/playbook-install-minio.yml
    sed -i -e "s@AZURE_SERVER_ADMIN@${AZURE_SERVER_ADMIN}@g" opsmgr-pipeline/ci/azure/tasks/ansible/playbook-install-minio.yml
    sed -i -e "s@STORAGE_ACCOUNT_NAME@${STORAGE_ACCOUNT_NAME}@g" opsmgr-pipeline/ci/azure/tasks/ansible/playbook-install-minio.yml

    mkdir ~/.ssh
    cp keys-out/* ~/.ssh/
    cd opsmgr-pipeline/ci/azure/tasks/ansible/
      ansible-playbook -i opsmgr-host playbook-install-minio.yml --private-key ~/.ssh/id_rsa
    cd ..
fi
