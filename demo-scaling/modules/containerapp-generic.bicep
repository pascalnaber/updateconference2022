param containerAppName string
param location string = resourceGroup().location
param tags object = {}
param environmentName string
@allowed([
  'Single'
  'Multiple'
])
param activeRevisionsMode string = 'Single'

param containerRegistry string = ''
param containerRegistryUsername string = ''
@secure()
param containerRegistryPassword string = ''

param useExternalIngress bool = false

param containerPort int = 80
param containerImage string
param envVars array = []
param resources object = {}

param minReplicas int = 0
param maxReplicas int = 10
param scaleRules array = []
param secrets array = []

resource environment 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: environmentName  
}

var containerRegistrySecret = [{
  name: 'container-registry-password'
  value: containerRegistryPassword
}]

var config = {
  activeRevisionsMode: activeRevisionsMode
  secrets: concat(secrets, !empty(containerRegistry) ? containerRegistrySecret : [])
  registries: !empty(containerRegistry) ? [
    {
      server: containerRegistry
      username: containerRegistryUsername
      passwordSecretRef: 'container-registry-password'
    }
  ] : []  
}

var ingress = {
  external: useExternalIngress
  targetPort: containerPort
  allowInsecure: false        
}

resource containerApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: containerAppName  
  location: location
  tags: tags
  properties: {    
    managedEnvironmentId: environment.id
    configuration: union(config, useExternalIngress? {ingress: ingress} : {})
    template: {      
      containers: [
        {
          image: containerImage
          name: containerAppName          
          env: envVars
          resources : !empty(resources)? resources : null
        }
      ]      
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
        rules: scaleRules
      }
    }
  }
}

output ingressFqdn string = useExternalIngress ? containerApp.properties.configuration.ingress.fqdn : ''
