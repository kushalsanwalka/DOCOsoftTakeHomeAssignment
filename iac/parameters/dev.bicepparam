using '../main.bicep'

param operationalInsightsWorkspaces = {
  counterApi: {
    name: 'docosoftcounterapidev'
    retentionInDays: 30
  }
}

param insightsComponents = {
  counterApi: {
    name: 'docosoftcounterapidev'
    logAnalyticsWorkspace: 'counterApi'
  }
}

param containerRegistryRegistries = {
  counterApi: {
    name: 'docosoftcounterapidev'
    sku: 'Basic'
  }
}

param serverFarms = {
  counterApi: {
    name: 'docosoftcounterapidev'
    sku: {
      name: 'B1'
      tier: 'Basic'
      capacity: 1
    }
  }
}

param webSites = {
  counterApi: {
    name: 'docosoftcounterapidev'
    serverFarm: 'counterApi'
    containerRegistry: 'counterApi'
    insightsComponent: 'counterApi'
    logAnalyticsWorkspace: 'counterApi'
    containerImageName: 'counterapi'
    containerPort: 8080
  }
}

param tags = {
  environment: 'dev'
}
