. ./vars.sh

QUEUE_CONNECTION_STRING=`az storage account show-connection-string -g $RESOURCE_GROUP --name $STORAGE_ACCOUNT_NAME --query connectionString --out json | tr -d '"'`

# az deployment group create --resource-group "$RESOURCE_GROUP" \
#   --template-file ./queue.json \
#   --parameters \
#     environment_name="$CONTAINERAPPS_ENVIRONMENT" \
#     queueconnection="$QUEUE_CONNECTION_STRING" \
#     location="$LOCATION"


az deployment sub create --location westeurope --template-file main.bicep \
--parameters \
  resourceGroupName="$RESOURCE_GROUP" \
  name="$CONTAINERAPPS_ENVIRONMENT" \
  location="$LOCATION" \
  queueConnectionString="$QUEUE_CONNECTION_STRING"