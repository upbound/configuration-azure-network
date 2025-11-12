import models.io.upbound.azurem.network.v1beta1 as networkv1beta1
import models.io.upbound.azurem.v1alpha1 as azurev1alpha1
import models.io.upbound.azurem.v1beta1 as azurev1beta1
import models.io.upbound.platform.azure.v1alpha1 as platformazurev1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

# observed composite resource
oxr = platformazurev1alpha1.Network{**option("params").oxr}
params = oxr.spec.parameters
# observed composed resources
_ocds = option("params").ocds
# desired composite resource
_dxr = option("params").dxr
# desired composed resources
dcds = option("params").dcds

_metadata = lambda name: str -> any {
    {
        name = name
        annotations = {"krm.kcl.dev/composition-resource-name" = name}
        labels = {"azure.platform.upbound.io/network-id" = params.id}
    }
}

# Helper function to add common spec fields
_add_common_spec_fields = lambda spec: any -> any {
    spec | {
        managementPolicies = params.managementPolicies or ["*"]
        providerConfigRef = {
            kind = "ProviderConfig"
            name = params.providerConfigName
        }
    }
}

# Base network resources
_base_resources = [
    # Resource Group
    azurev1beta1.ResourceGroup {
        metadata = _metadata("${params.id}-rg")
        spec = _add_common_spec_fields(azurev1beta1.AzuremUpboundIoV1beta1ResourceGroupSpec {
            forProvider = {
                location = params.region
            }
        })
    }

    # Virtual Network
    networkv1beta1.VirtualNetwork {
        metadata = _metadata("${params.id}-vnet")
        spec = _add_common_spec_fields(networkv1beta1.NetworkAzuremUpboundIoV1beta1VirtualNetworkSpec {
            forProvider = {
                location = params.region
                addressSpace = [params.addressRange]
                resourceGroupNameSelector = {
                    matchControllerRef = True
                }
            }
        })
    }

    # Subnet for general use
    networkv1beta1.Subnet {
        metadata = _metadata("${params.id}-sn") | {
            labels: {
                "azure.platform.upbound.io/subnet-service-type" = "general"
            }
        }
        spec = _add_common_spec_fields(networkv1beta1.NetworkAzuremUpboundIoV1beta1SubnetSpec {
            forProvider = {
                addressPrefixes = [params.generalSubnetRange]
                resourceGroupNameSelector = {
                    matchControllerRef = True
                }
                serviceEndpoints = ["Microsoft.Sql"]
                virtualNetworkNameSelector = {
                    matchControllerRef = True
                }
            }
        })
    }
]

# Database subnets (optional)
_subnets_from_spec = params.databaseSubnets or []
_database_subnets = [
    networkv1beta1.Subnet {
        metadata = _metadata("${params.id}-db-sn-${index}") | {
            labels: {
                "azure.platform.upbound.io/subnet-service-type" = subnet.serviceType
            }
        }
        spec = _add_common_spec_fields(networkv1beta1.NetworkAzuremUpboundIoV1beta1SubnetSpec {
            forProvider = {
                addressPrefixes = [subnet.addressRange]
                delegation = [{
                    name = "fs"
                    serviceDelegation = {
                        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
                        name = "Microsoft.DBforPostgreSQL/flexibleServers" if subnet.serviceType == "postgres" else "Microsoft.DBforMySQL/flexibleServers"
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
        })
    } for index, subnet in _subnets_from_spec
]

items = _base_resources + _database_subnets
