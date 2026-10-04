param location string = resourceGroup().location
param tags object
param webSites object
param serverFarms object
param containerRegistryRegistries object
param insightsComponents object
param operationalInsightsWorkspaces object
param containerImageTag string

// Built-in role: AcrPull
var acrPullRoleDefinitionId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '7f951dda-4ed3-4680-a7ca-43fe172d538d'
)

resource serverFarm 'Microsoft.Web/serverfarms@2025-03-01' existing = {
  name: serverFarms[webSites.serverFarm].name
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2025-11-01' existing = {
  name: containerRegistryRegistries[webSites.containerRegistry].name
}

resource insightsComponent 'Microsoft.Insights/components@2020-02-02' existing = {
  name: insightsComponents[webSites.insightsComponent].name
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2026-03-01' existing = {
  name: operationalInsightsWorkspaces[webSites.logAnalyticsWorkspace].name
}

resource thisWebSites 'Microsoft.Web/sites@2025-03-01' = {
  name: webSites.name
  location: location
  tags: union(tags, webSites.?tags ?? {})
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: serverFarm.id
    httpsOnly: true
    clientAffinityEnabled: false
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/${webSites.containerImageName}:${containerImageTag}'
      acrUseManagedIdentityCreds: true
      alwaysOn: webSites.?alwaysOn ?? true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      http20Enabled: true
      appSettings: [
        {
          // Tells the App Service front end which port the container listens on.
          name: 'WEBSITES_PORT'
          value: string(webSites.?containerPort ?? 8080)
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
        {
          name: 'ASPNETCORE_FORWARDEDHEADERS_ENABLED'
          value: 'true'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: insightsComponent.properties.ConnectionString
        }
      ]
    }
  }
}

resource thisWebSitesAcrPull 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, thisWebSites.id, acrPullRoleDefinitionId)
  scope: containerRegistry
  properties: {
    roleDefinitionId: acrPullRoleDefinitionId
    principalId: thisWebSites.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource thisWebSitesDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'send-to-log-analytics'
  scope: thisWebSites
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'AppServiceConsoleLogs'
        enabled: true
      }
      {
        category: 'AppServiceHTTPLogs'
        enabled: true
      }
      {
        category: 'AppServicePlatformLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output name string = thisWebSites.name
output hostName string = thisWebSites.properties.defaultHostName
