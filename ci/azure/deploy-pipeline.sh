#!/bin/bash

PIPELINE_NAME=mongodb-mms
ALIAS=ci.syolab
CREDENTIALS="credentials.yml"

echo y | fly -t "${ALIAS}" sp -p "${PIPELINE_NAME}" -c pipeline.yml -l "${CREDENTIALS}"
fly -t "${ALIAS}" expose-pipeline  -p  "${PIPELINE_NAME}"
