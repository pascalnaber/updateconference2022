az account set --subscription Sponsorship
CONTAINERREGISTRY_NAME=romedockerimages

# rg-demoenvironment

az deployment sub create --location westeurope --template-file main.bicep \
--parameters @main.parameters.json