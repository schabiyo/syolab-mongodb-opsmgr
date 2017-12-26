#!/bin/bash
set -e

## Use sed to replace the parameters in configureOpsMrg.jsvar
echo "Configuring Ops Manager"
## This depends if SSL is supposed to be configured or not
## Check if a key pem has been specified

opsDomain="${OPSMGR_SERVER_HOSTNAME}.${AZURE_RESOURCE_LOCATION}.cloudapp.azure.com";

if [ ${#OPSMGR_CENTRAL_URL} -gt 3 ];then
    opsDomain="${OPSMGR_CENTRAL_URL}"
fi


if [ ${#OPSMGR_PEM} -gt 50 ]; then

  #Get the SSH key from the configs adn add it to the ssh folder
  mkdir ~/.ssh
  #Had to do this as the key is being read in one single line
  printf "%s\n" "-----BEGIN RSA PRIVATE KEY-----" >> ~/.ssh/id_rsa
  printf "%s\n" $OPSMGR_SSHKEY_PRIVATE | tail -n +5 | head -n -4 >>  ~/.ssh/id_rsa
  printf "%s" "-----END RSA PRIVATE KEY-----" >> ~/.ssh/id_rsa

  echo $OPSMGR_SSHKEY_PUBLIC >> ~/.ssh/id_rsa.pub

  # Create the PEM file
  printf "%s\n" "-----BEGIN RSA PRIVATE KEY-----" >> ~/opsmanager.pem
  printf "%s\n" $OPSMGR_PEM | tail -n +5 | head -n -4 >>  ~/opsmanager.pem
  printf "%s" "-----END RSA PRIVATE KEY-----" >> ~/opsmanager.pem


  # Add this to the config file
  echo -e "Host=${OPSMGR_SERVER_HOSTNAME}.${AZURE_RESOURCE_LOCATION}.cloudapp.azure.com\nIdentityFile=~/.ssh/id_rsa\nUser=${AZURE_SERVER_ADMIN}" >> ~/.ssh/config
  chmod 600 ~/.ssh/config
  chmod 600 ~/.ssh/id_rsa*
  chmod 600 ~/opsmanager.pem

  cd opsmgr-pipeline/ci/azure/tasks/ansible/
   ansible-playbook -i opsmgr-host playbook-upload-pem.yml --private-key ~/.ssh/id_rsa
  cd ..

  opsUrl="https://${opsDomain}:8443";
else
  opsUrl="http://${opsDomain}:8080";
fi


sed -i -e "s~OPSMGR_URL~${opsUrl}~g" opsmgr-pipeline/ci/js/config.json
sed -i -e "s~OPSMGR_REGISTRATION_USERNAME~${OPSMGR_REGISTRATION_USERNAME}~g" opsmgr-pipeline/ci/js/config.json
sed -i -e "s@OPSMGR_REGISTRATION_PASSWORD@${OPSMGR_REGISTRATION_PASSWORD}@g" opsmgr-pipeline/ci/js/config.json
sed -i -e "s@OPSMGR_REGISTRATION_FIRSTNAME@${OPSMGR_REGISTRATION_FIRSTNAME}@g" opsmgr-pipeline/ci/js/config.json
sed -i -e "s@OPSMGR_REGISTRATION_LASTNAME@${OPSMGR_REGISTRATION_LASTNAME}@g" opsmgr-pipeline/ci/js/config.json

sed -i -e "s~OPSMGR_CONFIG_EMAIL_FROM~${OPSMGR_CONFIG_EMAIL_FROM}~g" opsmgr-pipeline/ci/js/config.json
sed -i -e "s~OPSMGR_CONFIG_EMAIL_REPLYTO~${OPSMGR_CONFIG_EMAIL_REPLYTO}~g" opsmgr-pipeline/ci/js/config.json
sed -i -e "s~OPSMGR_CONFIG_EMAIL_ADMIN~${OPSMGR_CONFIG_EMAIL_ADMIN}~g" opsmgr-pipeline/ci/js/config.json
sed -i -e "s@OPSMGR_CONFIG_EMAIL_TRANSPORT@${OPSMGR_CONFIG_EMAIL_TRANSPORT}@g" opsmgr-pipeline/ci/js/config.json
sed -i -e "s@OPSMGR_CONFIG_EMAIL_HOSTNAME@${OPSMGR_CONFIG_EMAIL_HOSTNAME}@g" opsmgr-pipeline/ci/js/config.json
sed -i -e "s@OPSMGR_CONFIG_EMAIL_PORT@${OPSMGR_CONFIG_EMAIL_PORT}@g" opsmgr-pipeline/ci/js/config.json


## Run the playbook that will upload the pem file to the host

## run node

cd opsmgr-pipeline/ci/js/
    npm i puppeteer
    npm install
    node configureOpsMrg.js
cd ..
