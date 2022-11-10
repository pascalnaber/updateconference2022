. ./vars.sh

az group create --name $RESOURCEGROUP --location westeurope

az deployment group create --resource-group $RESOURCEGROUP --template-file containerapp.bicep \
--parameters containerImage=romedockerimages.azurecr.io/demo/helloworld:1 \
containerPort=80 \
useExternalIngress=true \
containerRegistry=romedockerimages.azurecr.io \
containerRegistryUsername=romedockerimages \
containerRegistryPassword=$(az acr credential show -n $CONTAINERREGISTRY_NAME --query "passwords[0].value"  -o tsv) \
containerAppName=$CONTAINERAPP_NAME \
environmentName=$ENVIRONMENT_NAME \
envVars=['{"name": "backgroundcolor", "value": "deepskyblue"},{"name": "text", "value": "Hello Update Conference!"}']