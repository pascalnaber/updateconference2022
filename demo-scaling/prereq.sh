. ./vars.sh

az account set --subscription "Sponsorship"

az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

az containerapp env create \
  --name $CONTAINERAPPS_ENVIRONMENT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION

az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location "$LOCATION" \
  --sku Standard_RAGRS \
  --kind StorageV2

QUEUE_CONNECTION_STRING=`az storage account show-connection-string -g $RESOURCE_GROUP --name $STORAGE_ACCOUNT_NAME --query connectionString --out json | tr -d '"'`

az storage queue create \
  --name 'myqueue' \
  --account-name $STORAGE_ACCOUNT_NAME \
  --connection-string $QUEUE_CONNECTION_STRING