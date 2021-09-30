@description('This array contains webapp details and settings')
param webapps array
param location string = resourceGroup().location
param alwaysOn bool

@description('This value to populated in pipeline')
@secure()
param instrumentationkey string

@description('This value to populated in pipeline')
@secure()
param appconfigconnectionstring string

@description('Custom domain used for the site')
param custom_domain string

@description('This value to populated in pipeline')
@secure()
param cert_thumbprint string

var appconfigurationappsetting = [
  {
    name: 'ConnectionStrings:AppConfig'
    value: appconfigconnectionstring
  }
]
var instrumentationkeyappsetting = [
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: instrumentationkey
  }
]

resource webapps_name 'Microsoft.Web/sites@2018-11-01' = [for item in webapps: {
  name: item.name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  tags: item.resourceTags
  properties: {
    siteConfig: {
      appSettings: concat(item.appsettings, instrumentationkeyappsetting, appconfigurationappsetting)
      alwaysOn: alwaysOn
      minTlsVersion: '1.2'
    }
    serverFarmId: '/subscriptions/${subscription().subscriptionId}/resourcegroups/${item.aspresourcegroup}/providers/Microsoft.Web/serverfarms/${item.appserviceplan}'
    clientAffinityEnabled: false
    httpsOnly: true
    hostNameSslStates: [
      {
        name: '${item.name}.${custom_domain}'
        sslState: 'SniEnabled'
        thumbprint: cert_thumbprint
        hostType: 'Standard'
      }
    ]
  }
}]

resource webapps_name_webapps_name_custom_domain 'Microsoft.Web/sites/hostnameBindings@2019-08-01' = [for item in webapps: {
  name: '${item.name}/${item.name}.${custom_domain}'
  properties: {
    sslState: 'SniEnabled'
    thumbprint: cert_thumbprint
  }
}]
