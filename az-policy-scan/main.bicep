param vmName string = 'testVM'
@secure()
param adminUsername string
@secure()
param adminPassword string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2020-06-01' = {
    name: '${vmName}Vnet'
    location: resourceGroup().location
    properties: {
        addressSpace: {
            addressPrefixes: ['10.0.0.0/16']
        }
    }
}
resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
    name: '${virtualNetwork.name}/default'
    properties: {
        addressPrefix: '10.0.0.0/24'
    }
}
resource publicIP 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
    name: '${vmName}PublicIP'
    location: resourceGroup().location
    properties: {
        publicIPAllocationMethod: 'Dynamic'
    }
}
resource networkInterface 'Microsoft.Network/networkInterfaces@2020-06-01' = {
    name: '${vmName}Nic'
    location: resourceGroup().location
    properties: {
        ipConfigurations: [{
            name: 'ipconfig1'
            properties: {
                privateIPAllocationMethod: 'Dynamic'
                subnet: {
                    id: subnet.id
                }
                publicIPAddress: {
                    id: publicIP.id
                }
            }
        }]
    }
}
resource virtualMachine 'Microsoft.Compute/virtualMachines@2020-06-01' = {
    name: vmName
    location: resourceGroup().location
    properties: {
        hardwareProfile: {
            vmSize: 'Standard_DS1_v2'
        }
        osProfile: {
            computerName: vmName
            adminUsername: adminUsername
            adminPassword: adminPassword
        }
        storageProfile: {
            imageReference: {
                publisher: 'MicrosoftWindowsServer'
                offer: 'WindowsServer'
                sku: '2016-Datacenter'
                version: 'latest'
            }
            osDisk: {
                createOption: 'FromImage'
            }
        }
        networkProfile: {
            networkInterfaces: [{
                id: networkInterface.id
            }]
        }
    }
}
