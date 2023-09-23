param name string = 'gha-runner'
param location string = 'westus2'
// param environmentId string

@secure()
param pat string

@secure()
param registry_password string
param environmentName string = 'gha-runner-env'
param workspaceName string = 'gha-runner-ws'
param workspaceLocation string = 'westus2'

// var repos = [
//   'aca-github-runners'
// ]

resource name_resource 'Microsoft.App/containerApps@2023-05-01' = {
  name: name
  location: location
  properties: {
    environmentId: environment.id
    configuration: {
      secrets: [
        {
          name: 'pat'
          value: pat
        }
        {
          name: 'registry-password'
          value: registry_password
        }
      ]
      registries: [
        {
          passwordSecretRef: 'registry-password'
          server: 'ggracr.azurecr.io'
          username: 'ggracr'
        }
      ]
      activeRevisionsMode: 'Single'
      ingress: {
        external: false
      }
    }
    template: {
      containers: [
        {
          name: 'gh-runner-image'
          image: 'ggracr.azurecr.io/github-runner:v4'
          command: []
          env: [
            {
              name: 'GHUSER'
              value: 'Gurmeet-Sandhu'
            }
            {
              name: 'REPO'
              value: 'aca-github-runners'
            }
            {
              name: 'PAT'
              secretRef: 'pat'
            }
          ]
          resources: {
              cpu: json('1.0')
              memory: '2.0Gi'
          }
      }
      ]
      scale: {
        minReplicas: 1
        // maxReplicas: 5
        // rules: [
        //   {
        //     custom:{
        //       auth: [
        //         {
        //           secretRef: 'pat'
        //           triggerParameter: 'personalAccessToken'
        //         }
        //       ]
        //       metadata: {
        //         owner: 'Gurmeet-Sandhu'
        //         runnerScope: 'repo'
        //         repos : repos
        //       }
        //       type: 'github-runner'
        //     }
        //   }
        // ]
      }
    }
  }
  dependsOn: [
    
  ]
}

resource environment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: environmentName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: reference('Microsoft.OperationalInsights/workspaces/${workspaceName}', '2022-10-01').customerId
        sharedKey: listKeys('Microsoft.OperationalInsights/workspaces/${workspaceName}', '2022-10-01').primarySharedKey
      }
    }
  }
  dependsOn: [
    workspace
  ]
}

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: workspaceLocation
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
    workspaceCapping: {
    }
  }
  dependsOn: []
}
