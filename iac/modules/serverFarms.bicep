param location string = resourceGroup().location
param tags object
param serverFarms object

resource thisServerFarms 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: serverFarms.name
  location: location
  tags: union(tags, serverFarms.?tags ?? {})
  kind: 'linux'
  sku: serverFarms.sku
  properties: {
    reserved: true // required for Linux
  }
}
