#!/bin/bash
set -e

## Use sed to replace the parameters in configureOpsMrg.jsvar
echo "Configuring Ops Manager"

opsUrl="${OPSMGR_SERVER_HOSTNAME}.${AZURE_RESOURCE_LOCATION}.cloudapp.azure.com:8080";

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

## run node

cd opsmgr-pipeline/ci/js/
npm i puppeteer
npm install
node configureOpsMrg.js

cd ..
