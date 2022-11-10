param acrName string

resource acr 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: acrName  
  scope: resourceGroup('DeployTime')
}

output ACR object = acr
