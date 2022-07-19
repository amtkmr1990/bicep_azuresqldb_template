targetScope = 'subscription'

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

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'name'
  location: location
}


module sqlserver 'Module/sqldb.bicep' = {
  scope: resourceGroup
  name: 'sqlserverdeployment'
  params: {
    dbServerName: dbServerName
    sqlDbName: sqlDbName
    location: location
    ADGroupAdmin: ADGroupAdmin
    sid: sid
    subnetIdForSqlPrivateLink: subnetIdForSqlPrivateLink
    tenantId: tenantId
    tags: tags
  }
}
