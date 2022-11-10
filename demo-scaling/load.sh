. ./vars.sh

NUMBER_OF_MESSAGES=20000

QUEUE_CONNECTION_STRING=`az storage account show-connection-string -g $RESOURCE_GROUP --name $STORAGE_ACCOUNT_NAME --query connectionString --out json | tr -d '"'`

./load/LoadGen.exe $QUEUE_CONNECTION_STRING $QUEUE_NAME $NUMBER_OF_MESSAGES