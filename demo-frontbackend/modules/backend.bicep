param name string
param location string
param image string
param acrName string

var containerAppName = 'backend'

module containerApp 'containerapp.bicep' = {
  name: 'containerapp-${containerAppName}'
  params: {
    name: name
    location: location
    containerAppName: containerAppName
    image: image
    ingress: false
    acrName: acrName
  }
}
