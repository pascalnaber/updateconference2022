param name string
param location string
param image string
param acrName string

var containerAppName = 'frontend'

resource backend 'Microsoft.App/containerApps@2022-03-01' existing = {
  name: '${name}backend'
}

var resourceToken = toLower(uniqueString(subscription().id, name, location))
var tags = { 'azd-env-name': name }
var abbrs = loadJsonContent('../abbreviations.json')

resource acr 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: acrName
  scope: resourceGroup('gaming')
}

resource env 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: '${abbrs.appManagedEnvironments}${resourceToken}'
}

// We have to use ${name}service_name for now because we don't deploy it in azd provision and azd deploy won't find it
// But the backup search logic will find it via this name.
resource containerapp 'Microsoft.App/containerApps@2022-03-01' = {
  name: '${name}${containerAppName}'
  location: location
  tags: union(tags, { 'azd-service-name': containerAppName })
  properties: {
    managedEnvironmentId: env.id
    configuration: {
      activeRevisionsMode: 'single'
      secrets: [
        {
          name: 'container-registry-password'
          value: acr.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: '${acr.name}.azurecr.io'
          username: acr.name
          passwordSecretRef: 'container-registry-password'
        }
      ]
      ingress: { 
        external: true
        targetPort: 80
      }
    }
    template: {
      containers: [
        {
          image: image
          name: containerAppName
          env: [           
            {
              name: 'LeaderboardWebApiBaseUrl'
              value: 'https://${backend.properties.configuration.ingress.fqdn}'
            }           
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}
