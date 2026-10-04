param location string = resourceGroup().location
param tags object
param operationalInsightsWorkspaces object

resource thisOperationalInsightsWorkspaces 'Microsoft.OperationalInsights/workspaces@2026-03-01' = {
  name: operationalInsightsWorkspaces.name
  location: location
  tags: union(tags, operationalInsightsWorkspaces.?tags ?? {})
  properties: {
    sku: {
      name: operationalInsightsWorkspaces.?sku ?? 'PerGB2018'
    }
    retentionInDays: operationalInsightsWorkspaces.?retentionInDays ?? 30
  }
}
