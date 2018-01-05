#!/bin/bash
#
## @file                getOauthToken.sh
## @author              Sani Chabi Yo
## @section DESCRIPTION A script which retrieve a OAUTH token from Azure AD given a Service Principal


# gloabal variables
OAUTH_RESOURCE="https%3A%2F%2Fmanagement.core.windows.net%2F"

getToken(){
  CURL_COMMAND=" -H 'Host: login.windows.net ' -X POST -d 'grant_type=client_credentials&client_id=CLIENT-ID&client_secret=CLIENT-SECRET&resource=https%3A%2F%2Fmanagement.core.windows.net%2F' https://login.windows.net/TENANT-ID/oauth2/token"
  # local variable x and y with passed args
  local tenant_id=$1
  local client_id=$2
  local client_secret=$3
  local responsevar=$4

  NEW_CURL_COMMAND=$(sed  "s@TENANT-ID@${tenant_id}@g" <<< $CURL_COMMAND)
  NEW_CURL_COMMAND=$(sed  "s@CLIENT-ID@${client_id}@g" <<< $NEW_CURL_COMMAND)
  NEW_CURL_COMMAND=$(sed  "s~CLIENT-SECRET~${client_secret}~g" <<< $NEW_CURL_COMMAND)

  result=$(eval curl $NEW_CURL_COMMAND)
  if [[ $result == *"error"* ]]; then
     echo $result
     exit 1
  else
      access_token=$(jq .access_token <<< $result)
      TRIMMED_RESULT="${access_token%\"}"
      TRIMMED_RESULT="${TRIMMED_RESULT#\"}"
      eval $responsevar="'$TRIMMED_RESULT'"
  fi
}
