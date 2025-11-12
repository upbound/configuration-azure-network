import models.io.upbound.platform.azure.v1alpha1 as platformazurev1alpha1
import models.io.upbound.azurem.v1beta1 as azurev1beta1
import models.io.upbound.azurem.network.v1beta1 as networkv1beta1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

_items = [
    metav1alpha1.CompositionTest{
        metadata.name = "test-network-with-postgresql-db"
        spec = {
            assertResources: [
                # The Network composite resource
                platformazurev1alpha1.Network{
                    metadata.name = "ref-azure-network"
                    spec.parameters = {
                        id = "ref-azure-network-from-xr"
                        region = "westus"
                        addressRange = "10.0.0.0/16"
                        generalSubnetRange = "10.0.1.0/24"
                        databaseSubnets = [
                            {
                                addressRange = "10.0.2.0/24"
                                serviceType = "postgres"
                            }
                        ]
                        managementPolicies = ["*"]
                        providerConfigName = "default"
                    }
                }

                # Resource Group
                azurev1beta1.ResourceGroup{
                    metadata.name = "ref-azure-network-from-xr-rg"
                    metadata.labels = {
                        "azure.platform.upbound.io/network-id" = "ref-azure-network-from-xr"
                    }
                    spec.forProvider = {
                        location = "westus"
                    }
                    spec.managementPolicies = ["*"]
                    spec.providerConfigRef = {
                        kind = "ProviderConfig"
                        name = "default"
                    }
                }

                # Virtual Network
                networkv1beta1.VirtualNetwork{
                    metadata.name = "ref-azure-network-from-xr-vnet"
                    metadata.labels = {
                        "azure.platform.upbound.io/network-id" = "ref-azure-network-from-xr"
                    }
                    spec.forProvider = {
                        location = "westus"
                        addressSpace = ["10.0.0.0/16"]
                        resourceGroupNameSelector = {
                            matchControllerRef = True
                        }
                    }
                    spec.managementPolicies = ["*"]
                    spec.providerConfigRef = {
                        kind = "ProviderConfig"
                        name = "default"
                    }
                }

                # General Subnet
                networkv1beta1.Subnet{
                    metadata.name = "ref-azure-network-from-xr-sn"
                    metadata.labels = {
                        "azure.platform.upbound.io/network-id" = "ref-azure-network-from-xr"
                        "azure.platform.upbound.io/subnet-service-type" = "general"
                    }
                    spec.forProvider = {
                        addressPrefixes = ["10.0.1.0/24"]
                        resourceGroupNameSelector = {
                            matchControllerRef = True
                        }
                        serviceEndpoints = ["Microsoft.Sql"]
                        virtualNetworkNameSelector = {
                            matchControllerRef = True
                        }
                    }
                    spec.managementPolicies = ["*"]
                    spec.providerConfigRef = {
                        kind = "ProviderConfig"
                        name = "default"
                    }
                }

                # Database Subnet with PostgreSQL delegation
                networkv1beta1.Subnet{
                    metadata.name = "ref-azure-network-from-xr-db-sn-0"
                    metadata.labels = {
                        "azure.platform.upbound.io/network-id" = "ref-azure-network-from-xr"
                        "azure.platform.upbound.io/subnet-service-type" = "postgres"
                    }
                    spec.forProvider = {
                        addressPrefixes = ["10.0.2.0/24"]
                        delegation = [{
                            name = "fs"
                            serviceDelegation = {
                                actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
                                name = "Microsoft.DBforPostgreSQL/flexibleServers"
                            }
                        }]
                        resourceGroupNameSelector = {
                            matchControllerRef = True
                        }
                        serviceEndpoints = ["Microsoft.Storage"]
                        virtualNetworkNameSelector = {
                            matchControllerRef = True
                        }
                    }
                    spec.managementPolicies = ["*"]
                    spec.providerConfigRef = {
                        kind = "ProviderConfig"
                        name = "default"
                    }
                }
            ]
            compositionPath = "apis/networks/composition.yaml"
            xrPath = "examples/network-xr-with-pg-db.yaml"
            xrdPath = "apis/networks/definition.yaml"
            timeoutSeconds = 120
            validate = False
        }
    },
    metav1alpha1.CompositionTest{
        metadata.name = "test-network-with-mysql-db"
        spec = {
            assertResources: [
                # The Network composite resource
                platformazurev1alpha1.Network{
                    metadata.name = "ref-azure-network"
                    spec.parameters = {
                        id = "ref-azure-network-from-xr"
                        region = "westus"
                        addressRange = "10.0.0.0/16"
                        generalSubnetRange = "10.0.1.0/24"
                        databaseSubnets = [
                            {
                                addressRange = "10.0.2.0/24"
                                serviceType = "mysql"
                            }
                        ]
                        managementPolicies = ["*"]
                        providerConfigName = "default"
                    }
                }

                # Resource Group
                azurev1beta1.ResourceGroup{
                    metadata.name = "ref-azure-network-from-xr-rg"
                    metadata.labels = {
                        "azure.platform.upbound.io/network-id" = "ref-azure-network-from-xr"
                    }
                    spec.forProvider = {
                        location = "westus"
                    }
                    spec.managementPolicies = ["*"]
                    spec.providerConfigRef = {
                        kind = "ProviderConfig"
                        name = "default"
                    }
                }

                # Virtual Network
                networkv1beta1.VirtualNetwork{
                    metadata.name = "ref-azure-network-from-xr-vnet"
                    metadata.labels = {
                        "azure.platform.upbound.io/network-id" = "ref-azure-network-from-xr"
                    }
                    spec.forProvider = {
                        location = "westus"
                        addressSpace = ["10.0.0.0/16"]
                        resourceGroupNameSelector = {
                            matchControllerRef = True
                        }
                    }
                    spec.managementPolicies = ["*"]
                    spec.providerConfigRef = {
                        kind = "ProviderConfig"
                        name = "default"
                    }
                }

                # General Subnet
                networkv1beta1.Subnet{
                    metadata.name = "ref-azure-network-from-xr-sn"
                    metadata.labels = {
                        "azure.platform.upbound.io/network-id" = "ref-azure-network-from-xr"
                        "azure.platform.upbound.io/subnet-service-type" = "general"
                    }
                    spec.forProvider = {
                        addressPrefixes = ["10.0.1.0/24"]
                        resourceGroupNameSelector = {
                            matchControllerRef = True
                        }
                        serviceEndpoints = ["Microsoft.Sql"]
                        virtualNetworkNameSelector = {
                            matchControllerRef = True
                        }
                    }
                    spec.managementPolicies = ["*"]
                    spec.providerConfigRef = {
                        kind = "ProviderConfig"
                        name = "default"
                    }
                }

                # Database Subnet with MySQL delegation
                networkv1beta1.Subnet{
                    metadata.name = "ref-azure-network-from-xr-db-sn-0"
                    metadata.labels = {
                        "azure.platform.upbound.io/network-id" = "ref-azure-network-from-xr"
                        "azure.platform.upbound.io/subnet-service-type" = "mysql"
                    }
                    spec.forProvider = {
                        addressPrefixes = ["10.0.2.0/24"]
                        delegation = [{
                            name = "fs"
                            serviceDelegation = {
                                actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
                                name = "Microsoft.DBforMySQL/flexibleServers"
                            }
                        }]
                        resourceGroupNameSelector = {
                            matchControllerRef = True
                        }
                        serviceEndpoints = ["Microsoft.Storage"]
                        virtualNetworkNameSelector = {
                            matchControllerRef = True
                        }
                    }
                    spec.managementPolicies = ["*"]
                    spec.providerConfigRef = {
                        kind = "ProviderConfig"
                        name = "default"
                    }
                }
            ]
            compositionPath = "apis/networks/composition.yaml"
            xrPath = "examples/network-xr-with-mysql-db.yaml"
            xrdPath = "apis/networks/definition.yaml"
            timeoutSeconds = 120
            validate = False
        }
    },
    metav1alpha1.CompositionTest{
        metadata.name = "test-network-without-db"
        spec = {
            assertResources: [
                # The Network composite resource
                platformazurev1alpha1.Network{
                    metadata.name = "ref-azure-network"
                    spec.parameters = {
                        id = "ref-azure-network-from-xr"
                        region = "westus"
                        addressRange = "10.0.0.0/16"
                        generalSubnetRange = "10.0.1.0/24"
                        managementPolicies = ["*"]
                        providerConfigName = "default"
                    }
                }

                # Resource Group
                azurev1beta1.ResourceGroup{
                    metadata.name = "ref-azure-network-from-xr-rg"
                    metadata.labels = {
                        "azure.platform.upbound.io/network-id" = "ref-azure-network-from-xr"
                    }
                    spec.forProvider = {
                        location = "westus"
                    }
                    spec.managementPolicies = ["*"]
                    spec.providerConfigRef = {
                        kind = "ProviderConfig"
                        name = "default"
                    }
                }

                # Virtual Network
                networkv1beta1.VirtualNetwork{
                    metadata.name = "ref-azure-network-from-xr-vnet"
                    metadata.labels = {
                        "azure.platform.upbound.io/network-id" = "ref-azure-network-from-xr"
                    }
                    spec.forProvider = {
                        location = "westus"
                        addressSpace = ["10.0.0.0/16"]
                        resourceGroupNameSelector = {
                            matchControllerRef = True
                        }
                    }
                    spec.managementPolicies = ["*"]
                    spec.providerConfigRef = {
                        kind = "ProviderConfig"
                        name = "default"
                    }
                }

                # General Subnet
                networkv1beta1.Subnet{
                    metadata.name = "ref-azure-network-from-xr-sn"
                    metadata.labels = {
                        "azure.platform.upbound.io/network-id" = "ref-azure-network-from-xr"
                    }
                    spec.forProvider = {
                        addressPrefixes = ["10.0.1.0/24"]
                        resourceGroupNameSelector = {
                            matchControllerRef = True
                        }
                        serviceEndpoints = ["Microsoft.Sql"]
                        virtualNetworkNameSelector = {
                            matchControllerRef = True
                        }
                    }
                    spec.managementPolicies = ["*"]
                    spec.providerConfigRef = {
                        kind = "ProviderConfig"
                        name = "default"
                    }
                }
            ]
            compositionPath = "apis/networks/composition.yaml"
            xrPath = "examples/network-xr.yaml"
            xrdPath = "apis/networks/definition.yaml"
            timeoutSeconds = 120
            validate = False
        }
    },
    metav1alpha1.CompositionTest{
        metadata.name = "test-network-with-multiple-dbs"
        spec = {
            assertResources: [
                # The Network composite resource
                platformazurev1alpha1.Network{
                    metadata.name = "ref-azure-network"
                    spec.parameters = {
                        id = "ref-azure-network-from-xr"
                        region = "westus"
                        addressRange = "10.0.0.0/16"
                        generalSubnetRange = "10.0.1.0/24"
                        databaseSubnets = [
                            {
                                addressRange = "10.0.2.0/24"
                                serviceType = "postgres"
                            },
                            {
                                addressRange = "10.0.3.0/24"
                                serviceType = "mysql"
                            }
                        ]
                        managementPolicies = ["*"]
                        providerConfigName = "default"
                    }
                }

                # Resource Group
                azurev1beta1.ResourceGroup{
                    metadata.name = "ref-azure-network-from-xr-rg"
                    metadata.labels = {
                        "azure.platform.upbound.io/network-id" = "ref-azure-network-from-xr"
                    }
                    spec.forProvider = {
                        location = "westus"
                    }
                    spec.managementPolicies = ["*"]
                    spec.providerConfigRef = {
                        kind = "ProviderConfig"
                        name = "default"
                    }
                }

                # Virtual Network
                networkv1beta1.VirtualNetwork{
                    metadata.name = "ref-azure-network-from-xr-vnet"
                    metadata.labels = {
                        "azure.platform.upbound.io/network-id" = "ref-azure-network-from-xr"
                    }
                    spec.forProvider = {
                        location = "westus"
                        addressSpace = ["10.0.0.0/16"]
                        resourceGroupNameSelector = {
                            matchControllerRef = True
                        }
                    }
                    spec.managementPolicies = ["*"]
                    spec.providerConfigRef = {
                        kind = "ProviderConfig"
                        name = "default"
                    }
                }

                # General Subnet
                networkv1beta1.Subnet{
                    metadata.name = "ref-azure-network-from-xr-sn"
                    metadata.labels = {
                        "azure.platform.upbound.io/network-id" = "ref-azure-network-from-xr"
                    }
                    spec.forProvider = {
                        addressPrefixes = ["10.0.1.0/24"]
                        resourceGroupNameSelector = {
                            matchControllerRef = True
                        }
                        serviceEndpoints = ["Microsoft.Sql"]
                        virtualNetworkNameSelector = {
                            matchControllerRef = True
                        }
                    }
                    spec.managementPolicies = ["*"]
                    spec.providerConfigRef = {
                        kind = "ProviderConfig"
                        name = "default"
                    }
                }

                # Database Subnet with PostgreSQL delegation
                networkv1beta1.Subnet{
                    metadata.name = "ref-azure-network-from-xr-db-sn-0"
                    metadata.labels = {
                        "azure.platform.upbound.io/network-id" = "ref-azure-network-from-xr"
                        "azure.platform.upbound.io/subnet-service-type" = "postgres"
                    }
                    spec.forProvider = {
                        addressPrefixes = ["10.0.2.0/24"]
                        delegation = [{
                            name = "fs"
                            serviceDelegation = {
                                actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
                                name = "Microsoft.DBforPostgreSQL/flexibleServers"
                            }
                        }]
                        resourceGroupNameSelector = {
                            matchControllerRef = True
                        }
                        serviceEndpoints = ["Microsoft.Storage"]
                        virtualNetworkNameSelector = {
                            matchControllerRef = True
                        }
                    }
                    spec.managementPolicies = ["*"]
                    spec.providerConfigRef = {
                        kind = "ProviderConfig"
                        name = "default"
                    }
                }

                # Database Subnet with MySQL delegation
                networkv1beta1.Subnet{
                    metadata.name = "ref-azure-network-from-xr-db-sn-1"
                    metadata.labels = {
                        "azure.platform.upbound.io/network-id" = "ref-azure-network-from-xr"
                        "azure.platform.upbound.io/subnet-service-type" = "mysql"
                    }
                    spec.forProvider = {
                        addressPrefixes = ["10.0.3.0/24"]
                        delegation = [{
                            name = "fs"
                            serviceDelegation = {
                                actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
                                name = "Microsoft.DBforMySQL/flexibleServers"
                            }
                        }]
                        resourceGroupNameSelector = {
                            matchControllerRef = True
                        }
                        serviceEndpoints = ["Microsoft.Storage"]
                        virtualNetworkNameSelector = {
                            matchControllerRef = True
                        }
                    }
                    spec.managementPolicies = ["*"]
                    spec.providerConfigRef = {
                        kind = "ProviderConfig"
                        name = "default"
                    }
                }
            ]
            compositionPath = "apis/networks/composition.yaml"
            xrPath = "examples/network-xr-with-multiple-dbs.yaml"
            xrdPath = "apis/networks/definition.yaml"
            timeoutSeconds = 120
            validate = False
        }
    }
]

items = _items
