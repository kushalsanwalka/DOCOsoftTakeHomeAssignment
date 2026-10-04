param location string = resourceGroup().location
param tags object
param containerRegistryRegistries object

resource thisContainerRegistryRegistries 'Microsoft.ContainerRegistry/registries@2025-11-01' = {
  name: containerRegistryRegistries.name
  location: location
  tags: union(tags, containerRegistryRegistries.?tags ?? {})
  sku: {
    name: containerRegistryRegistries.?sku ?? 'Basic'
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: 'Enabled'
  }
}

output name string = thisContainerRegistryRegistries.name
output loginServer string = thisContainerRegistryRegistries.properties.loginServer
