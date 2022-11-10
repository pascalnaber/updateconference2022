param name string
param image string
param location string
param containerAppName string
param ingress bool = false
param port int = 80
param acrName string

var resourceToken = toLower(uniqueString(subscription().id, name, location))
var tags = { 'azd-env-name': name }
var abbrs = loadJsonContent('../abbreviations.json')

// resource acr 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
//   name: acrName  
// }
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
          server: '${acrName}.azurecr.io'
          username: acrName
          passwordSecretRef: 'container-registry-password'
        }
      ]
      ingress: { 
        external: false
        targetPort: port
      }
    }
    template: {
      containers: [
        {
          image: image
          name: containerAppName
          env: [
            {
              name: 'ConnectionStrings__LeaderboardContext'
              value: 'Server=tcp:gamingdbserver${environment().suffixes.sqlServerHostname},1433;Initial Catalog=gaming-database;Persist Security Info=False;User ID=clouduser;Password=;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
            }           
            {
              name: 'Serilog__MinimumLevel__Default'
              value: 'Warning'
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
