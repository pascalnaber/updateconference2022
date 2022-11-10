az account set --subscription Sponsorship
CONTAINERREGISTRY_NAME=romedockerimages
RESOURCEGROUP=aca-frontend-backend
az group create --name $RESOURCEGROUP --location westeurope

az deployment group create --resource-group $RESOURCEGROUP --template-file backend.bicep \
--parameters @backend.parameters.json