#!/bin/bash
set -e

## Use sed to replace the parameters in configureOpsMrg.js


## run node

cd opsmgr-pipeline/ci/js/
npm i puppeteer
node configureOpsMrg.js
cd ..
