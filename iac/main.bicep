param location string = resourceGroup().location
param operationalInsightsWorkspaces object
param insightsComponents object
param containerRegistryRegistries object
param serverFarms object
param webSites object
param containerImageTag string = 'latest'
param tags object = {}

module thisOperationalInsightsWorkspaces 'modules/operationalInsightsWorkspaces.bicep' = {
  name: '${deployment().name}-law'
  params: {
    location: location
    tags: tags
    operationalInsightsWorkspaces: operationalInsightsWorkspaces.counterApi
  }
}

module thisInsightsComponents 'modules/insightsComponents.bicep' = {
  name: '${deployment().name}-appi'
  dependsOn: [
    thisOperationalInsightsWorkspaces
  ]
  params: {
    location: location
    tags: tags
    insightsComponents: insightsComponents.counterApi
    operationalInsightsWorkspaces: operationalInsightsWorkspaces
  }
}

module thisContainerRegistryRegistries 'modules/containerRegistryRegistries.bicep' = {
  name: '${deployment().name}-acr'
  params: {
    location: location
    tags: tags
    containerRegistryRegistries: containerRegistryRegistries.counterApi
  }
}

module thisServerFarms 'modules/serverFarms.bicep' = {
  name: '${deployment().name}-asp'
  params: {
    location: location
    tags: tags
    serverFarms: serverFarms.counterApi
  }
}

module thisWebSites 'modules/webSites.bicep' = {
  name: '${deployment().name}-app'
  dependsOn: [
    thisServerFarms
    thisContainerRegistryRegistries
    thisInsightsComponents
    thisOperationalInsightsWorkspaces
  ]
  params: {
    location: location
    tags: tags
    webSites: webSites.counterApi
    serverFarms: serverFarms
    containerRegistryRegistries: containerRegistryRegistries
    insightsComponents: insightsComponents
    operationalInsightsWorkspaces: operationalInsightsWorkspaces
    containerImageTag: containerImageTag
  }
}

// Consumed by the pipeline (push image, restart, smoke test).
output containerRegistryName string = thisContainerRegistryRegistries.outputs.name
output containerRegistryLoginServer string = thisContainerRegistryRegistries.outputs.loginServer
output webAppName string = thisWebSites.outputs.name
output webAppHostName string = thisWebSites.outputs.hostName
