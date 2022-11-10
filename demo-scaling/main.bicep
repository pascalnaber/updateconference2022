targetScope = 'subscription'

param resourceGroupName string

@minLength(1)
@maxLength(50)
@description('Name of the the environment.')
param name string

@minLength(1)
@description('Primary location for all resources')
param location string
param tags object = {}

param queueConnectionString string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

// module aca_environment './modules/containerapp-environment.bicep' = {
//   name: 'aca-environment'
//   scope: rg
//   params: {
//       location: location
//       environmentName: name
//       appInsightsName: name
//       workspaceName: name
//   }
// }

module queueReader './modules/containerapp-generic.bicep' = {
  name: 'queueReader'
  scope: rg
  params: {
      location: location
      containerAppName: 'queuereader'
      containerImage: 'mcr.microsoft.com/azuredocs/containerapps-queuereader'      
      environmentName: name
      activeRevisionsMode: 'Single'
      resources: {
        cpu: json('0.5')
        memory: '1Gi'
      }
      secrets: [
        {
          name: 'queueconnection'
          value: queueConnectionString
        }
      ]
      minReplicas: 1
      maxReplicas: 10
      scaleRules: [
        {
          name: 'myqueuerule'
          azureQueue: {
            auth: [
              {
                secretRef: 'queueconnection'
                triggerParameter: 'connection'
              }
            ]
            queueLength: 100
            queueName: 'myqueue'
          }
        }
      ]      
      envVars: [
        {
          name: 'QueueName'
          value: 'myqueue'
        }           
        {
          name: 'QueueConnectionString'
          secretRef: 'queueconnection'
        }
      ]
  }  
}
