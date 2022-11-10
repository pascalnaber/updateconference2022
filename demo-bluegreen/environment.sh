. ./vars.sh

az account --set --subscription Sponsorship
az group create --name $RESOURCEGROUP --location westeurope

az deployment group create --resource-group $RESOURCEGROUP --template-file containerapp-environment.bicep \
--parameters \
workspaceName=$WORKSPACE_NAME \
appInsightsName=$APPLICATIONINSIGHTS_NAME \
environmentName=$ENVIRONMENT_NAME