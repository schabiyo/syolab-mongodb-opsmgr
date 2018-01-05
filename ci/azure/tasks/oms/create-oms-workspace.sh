#!/bin/bash
set -e -x

source opsmgr-pipeline/ci/azure/tasks/oms/utils/pretty-echo.sh
source opsmgr-pipeline/ci/azure/tasks/oms/utils/getOauthToken.sh
source opsmgr-pipeline/ci/azure/tasks/oms/utils/getWorkspaceItem.sh
source opsmgr-pipeline/ci/azure/tasks/oms/utils/getWorkspaceUrl.sh



az login --service-principal -u "$AZURE_CLIENT_ID" -p "$AZURE_SECRET" --tenant "$AZURE_TENANT"
az account set --subscription "$AZURE_SUBSCRIPTION_ID"  &> /dev/null

MESSAGE="Getting an access token from AAD" ; simple_blue_echo

getToken $AZURE_TENANT $AZURE_CLIENT_ID $AZURE_SECRET token

MESSAGE="Creating hte worksapce Workspace " ; simple_blue_echo

 CURL_COMMAND=" -H 'Host: management.azure.com' -H 'Content-Type: application/json' -H 'Authorization: Bearer OAUTH-TOKEN' -X PUT -d '{\"properties\": {\"source\": \"Azure\",\"customerId\": \"\",\"portalUrl\": \"\",\"provisioningState\": \"\",\"sku\": {\"name\": \"OMS-WORKSPACE-SKU\"},\"features\": {\"legacy\": 0,\"searchVersion\": 0}},\"id\": \"\",\"name\": \"OMS-WORKSPACE-NAME\",\"type\": \"Microsoft.OperationalInsights/workspaces\",\"location\": \"RESOURCE-LOCATION\"}' https://management.azure.com/subscriptions/SUBSCRIPTION-ID/resourcegroups/RESOURCE-GROUP-NAME/providers/Microsoft.OperationalInsights/workspaces/OMS-WORKSPACE-NAME?api-version=2015-11-01-preview"

NEW_CURL_COMMAND=$(sed  "s@OAUTH-TOKEN@${token}@g" <<< $CURL_COMMAND)
NEW_CURL_COMMAND=$(sed  "s@TENANT-ID@${AZURE_TENANT}@g" <<< $NEW_CURL_COMMAND)
NEW_CURL_COMMAND=$(sed  "s@OMS-WORKSPACE-SKU@${OMS_WORKSPACE_SKU}@g" <<< $NEW_CURL_COMMAND)
NEW_CURL_COMMAND=$(sed  "s@OMS-WORKSPACE-NAME@${OMS_WORKSPACE_NAME}@g" <<< $NEW_CURL_COMMAND)
NEW_CURL_COMMAND=$(sed  "s@RESOURCE-GROUP-NAME@${AZURE_RESOURCE_GROUP}@g" <<< $NEW_CURL_COMMAND)
NEW_CURL_COMMAND=$(sed  "s@RESOURCE-LOCATION@${AZURE_RESOURCE_LOCATION}@g" <<< $NEW_CURL_COMMAND)
NEW_CURL_COMMAND=$(sed  "s@SUBSCRIPTION-ID@${AZURE_SUBSCRIPTION_ID}@g" <<< $NEW_CURL_COMMAND)

echo $NEW_CURL_COMMAND

#Check if we got a 200 back
result=$(eval curl $NEW_CURL_COMMAND)
echo result
if [[ $result == *"error"* ]]; then
   echo $result
   if [[ $result == *"The value provided for Id is invalid"* ]]; then
   	MESSAGE="==>Looks like te WOrkspace already exist"; simple_blue_echo
        #Get the Workspace
        getWorkspaceUrl $token $OMS_WORKSPACE_NAME $AZURE_RESOURCE_GROUP $AZURE_SUBSCRIPTION_ID portal_url
        MESSAGE="==>Please access the workspace using the following URL:${portal_url}" ; simple_blue_echo
        exit 0
   fi
   MESSAGE="==>Make sure a Workspace with the same name does not exist and try again.." ; simple_red_echo
   exit 1
else
   #Get the state
   workspace_state=$(jq .properties.provisioningState <<< $result)
   echo "provisioningState:" $provisioningState
fi

MESSAGE="Waiting until Workspace is successfully created " ; simple_blue_echo

#Try for a maximum of 5 minutes to check if the OMS Worskapce was successfull
## sleep in bash for loop ##
for i in {1..5}
do
   #Get the Workspace Status
   getWorkspaceItemStatus $token $OMS_WORKSPACE_NAME $AZURE_RESOURCE_GROUP $AZURE_SUBSCRIPTION_ID state
   echo "provisioningState:"$state
   if [[ $state == "Succeeded" ]]; then
     portal_url=$(jq .properties.portalUrl <<< $result)
     MESSAGE="Workspace was successully created and can be accessed using the following URL:${portal_url}" ; simple_green_echo
     exit 0
   elif (( $state == "Creating" || $state == "ProvisioningAccount" )); then
     echo "Waiting..."
     sleep 1m
   else
     #The creation failes for a raison
     MESSAGE="==>The workspace create failed for a raison, please make sure the workspace name is unique and try again." ; simple_red_echo
     exit 1
   fi
done




