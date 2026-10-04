param location string = resourceGroup().location
param tags object
param insightsComponents object
param operationalInsightsWorkspaces object

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2026-03-01' existing = {
  name: operationalInsightsWorkspaces[insightsComponents.logAnalyticsWorkspace].name
}

resource thisInsightsComponents 'Microsoft.Insights/components@2020-02-02' = {
  name: insightsComponents.name
  location: location
  tags: union(tags, insightsComponents.?tags ?? {})
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
    IngestionMode: 'LogAnalytics'
  }
}
