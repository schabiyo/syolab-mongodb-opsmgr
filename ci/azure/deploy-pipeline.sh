#!/bin/bash

PIPELINE_NAME=mongodb-opsmgr
ALIAS=syolab
CREDENTIALS="credentials.yml"

echo y | ./../../local_fly -t "${ALIAS}" sp -p "${PIPELINE_NAME}" -c pipeline.yml -l "${CREDENTIALS}"
./../../local_fly -t "${ALIAS}" expose-pipeline  -p  "${PIPELINE_NAME}"
