param location string 
param dbServerName string 
param sqlDbName string 
param tags object 
@description('Enter the AD group name for Sql Admin Login')
param ADGroupAdmin string 
@description('sid of the AD group name for Sql Admin Login')
param sid string 
@description('tenant id')
param tenantId string 
@description('subnet id where sql server will be private linked')
param subnetIdForSqlPrivateLink string 

//privateendpoint name for the sql server
var privateEndpointName = '${dbServerName}-link'

resource sqlserver 'Microsoft.Sql/servers@2021-11-01-preview' = {
  properties: {
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    administrators: {
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
      login: ADGroupAdmin
      sid: sid
      tenantId: tenantId
      azureADOnlyAuthentication: true
    }
    restrictOutboundNetworkAccess: 'Disabled'
  }
  location: location
  tags: tags
  name: dbServerName
}

@description('Generated from /subscriptions/bba2c874-6268-48fb-b2c2-4b110514f730/resourceGroups/rg-dbsrv-dev/providers/Microsoft.Sql/servers/dbsrv-amtkmr-dev/databases/db-amtkmr-dev')
resource sqldb 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  sku: {
    name: 'Standard'
    tier: 'Standard'
    capacity: 10
  }
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    requestedBackupStorageRedundancy: 'Local'
    isLedgerOn: false
  }
  location: location
  tags: tags
  name: '${sqlserver.name}/${sqlDbName}'
}


resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetIdForSqlPrivateLink
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: sqlserver.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}
