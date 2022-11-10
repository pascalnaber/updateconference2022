param containerImage string
param containerPort int
param useExternalIngress bool

param containerRegistry string
param containerRegistryUsername string
@secure()
param containerRegistryPassword string


param envVars array = []
param containerAppName string

param environmentName string

param location string = resourceGroup().location
var minReplicas = 0

resource environment 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: environmentName  
}

resource containerApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: containerAppName  
  location: location
  
  properties: {
    
    managedEnvironmentId: environment.id
    configuration: {
      activeRevisionsMode: 'Multiple'
      secrets: [
        {
          name: 'container-registry-password'
          value: containerRegistryPassword
        }       
      ]
      registries: [
        {
          server: containerRegistry
          username: containerRegistryUsername
          passwordSecretRef: 'container-registry-password'
        }
      ]
      ingress: {
        external: useExternalIngress
        targetPort: containerPort
        allowInsecure: false
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
    }
    template: {
      
      containers: [
        {
          image: containerImage
          name: containerAppName          
          env: envVars
          resources: {
            cpu: json('.25')
            memory: '.5Gi'
          }
        }
      ]
      
      scale: {
        minReplicas: minReplicas
        maxReplicas: 10
        rules: [
          {
            name: 'cpuscalingrule'
            custom: {
            type: 'cpu'
            metadata: {
              type: 'Utilization'
              value: '50'
            }
          }
        }
        ]
      }
    }
  }
}
