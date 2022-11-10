param containerAppName string
param location string = resourceGroup().location
param environmentName string
param queueConnectionString string

resource environment 'Microsoft.App/managedEnvironments@2022-01-01-preview' existing = {
  name: environmentName  
}

resource containerApp 'Microsoft.App/containerApps@2022-01-01-preview' = {
  name: containerAppName  
  location: location  
  properties: {    
    managedEnvironmentId: environment.id
    configuration: {
      activeRevisionsMode: 'Single'
      secrets: [
        {
          name: 'queueconnection'
          value: queueConnectionString
        }
      ]            
    }
    template: {      
      containers: [
        {
          image: 'mcr.microsoft.com/azuredocs/containerapps-queuereader'    
          name: 'queuereader'          
          env: [
            {
              name: 'QueueName'
              value: 'myqueue'
            }           
            {
              name: 'QueueConnectionString'
              secretRef: 'queueconnection'
            }
          ]
          resources : {
            cpu: json('0.5')
            memory: '1Gi'
          }
        }
      ]      
      scale: {
        minReplicas: 1
        maxReplicas: 10
        rules: [
          {
            name: 'myqueuerule'
            azureQueue: {
              queueName: 'myqueue'
              queueLength: 100
              auth: [
                {
                  secretRef: 'queueconnection'
                  triggerParameter: 'connection'
                }
              ]
            }
          }
        ]
      }
    }
  }
}


output ingressFqdn string = containerApp.properties.configuration.ingress.fqdn
