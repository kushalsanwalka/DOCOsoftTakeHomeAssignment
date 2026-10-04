using '../main.bicep'

param operationalInsightsWorkspaces = {
  counterApi: {
    name: 'docosoftcounterapiprod'
    retentionInDays: 90
  }
}

param insightsComponents = {
  counterApi: {
    name: 'docosoftcounterapiprod'
    logAnalyticsWorkspace: 'counterApi'
  }
}

param containerRegistryRegistries = {
  counterApi: {
    name: 'docosoftcounterapiprod'
    sku: 'Standard'
  }
}

param serverFarms = {
  counterApi: {
    name: 'docosoftcounterapiprod'
    sku: {
      name: 'P0V4'
      capacity: 1
    }
  }
}

param webSites = {
  counterApi: {
    name: 'docosoftcounterapiprod'
    serverFarm: 'counterApi'
    containerRegistry: 'counterApi'
    insightsComponent: 'counterApi'
    logAnalyticsWorkspace: 'counterApi'
    containerImageName: 'counterapi'
    containerPort: 8080
  }
}

param tags = {
  environment: 'prod'
}
