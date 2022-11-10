az acr login --name romedockerimages
docker images
docker tag demo:latest romedockerimages.azurecr.io/demo/helloworld:1
docker tag demo:latest romedockerimages.azurecr.io/demo/helloworld:2

docker push romedockerimages.azurecr.io/demo/helloworld:1
docker push romedockerimages.azurecr.io/demo/helloworld:2