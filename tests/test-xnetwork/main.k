import models.io.upbound.platform.azure.v1alpha1 as platformazurev1alpha1
import models.io.upbound.azure.v1beta1 as azurev1beta1
import models.io.upbound.azure.network.v1beta2 as networkv1beta2
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

_items = [
    metav1alpha1.CompositionTest{
        metadata.name = "test-xnetwork-with-db"
        spec = {
            assertResources: [
                # The XNetwork composite resource
                platformazurev1alpha1.XNetwork{
                    metadata.name = "ref-azure-network"
                    spec.parameters = {
                        id = "ref-azure-network-from-xr"
                        region = "westus"
                        addressSpace = "10.0.0.0/16"
                        generalSubnetPrefix = "10.0.1.0/24"
                        databaseSubnetPrefix = "10.0.2.0/24"
                        deletionPolicy = "Delete"
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
                    spec.deletionPolicy = "Delete"
                    spec.providerConfigRef.name = "default"
                }

                # Virtual Network
                networkv1beta2.VirtualNetwork{
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
                    spec.deletionPolicy = "Delete"
                    spec.providerConfigRef.name = "default"
                }

                # General Subnet
                networkv1beta2.Subnet{
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
                    spec.deletionPolicy = "Delete"
                    spec.providerConfigRef.name = "default"
                }

                # Database Subnet
                networkv1beta2.Subnet{
                    metadata.name = "ref-azure-network-from-xr-db-sn"
                    metadata.labels = {
                        "azure.platform.upbound.io/network-id" = "ref-azure-network-from-xr"
                    }
                    spec.forProvider = {
                        addressPrefixes = ["10.0.2.0/24"]
                        delegation = [
                            {
                                name = "fs-postgresql"
                                serviceDelegation = {
                                    actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
                                    name = "Microsoft.DBforPostgreSQL/flexibleServers"
                                }
                            },
                            {
                                name = "fs-mysql"
                                serviceDelegation = {
                                    actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
                                        name = "Microsoft.DBforMySQL/flexibleServers"
                                }
                            }
                        ]
                        resourceGroupNameSelector = {
                            matchControllerRef = True
                        }
                        serviceEndpoints = ["Microsoft.Storage"]
                        virtualNetworkNameSelector = {
                            matchControllerRef = True
                        }
                    }
                    spec.deletionPolicy = "Delete"
                    spec.providerConfigRef.name = "default"
                }
            ]
            compositionPath = "apis/xnetworks/composition.yaml"
            xrPath = "examples/network-xr-with-db.yaml"
            xrdPath = "apis/xnetworks/definition.yaml"
            timeoutSeconds = 120
            validate = False
        }
    },
    metav1alpha1.CompositionTest{
        metadata.name = "test-xnetwork-without-db"
        spec = {
            assertResources: [
                # The XNetwork composite resource
                platformazurev1alpha1.XNetwork{
                    metadata.name = "ref-azure-network"
                    spec.parameters = {
                        id = "ref-azure-network-from-xr"
                        region = "westus"
                        addressSpace = "10.0.0.0/16"
                        generalSubnetPrefix = "10.0.1.0/24"
                        deletionPolicy = "Delete"
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
                    spec.deletionPolicy = "Delete"
                    spec.providerConfigRef.name = "default"
                }

                # Virtual Network
                networkv1beta2.VirtualNetwork{
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
                    spec.deletionPolicy = "Delete"
                    spec.providerConfigRef.name = "default"
                }

                # General Subnet
                networkv1beta2.Subnet{
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
                    spec.deletionPolicy = "Delete"
                    spec.providerConfigRef.name = "default"
                }
            ]
            compositionPath = "apis/xnetworks/composition.yaml"
            xrPath = "examples/network-xr.yaml"
            xrdPath = "apis/xnetworks/definition.yaml"
            timeoutSeconds = 120
            validate = False
        }
    }
]

items = _items
