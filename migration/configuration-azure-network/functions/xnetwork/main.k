import models.io.upbound.azure.network.v1beta1 as networkv1beta1
import models.io.upbound.azure.network.v1beta2 as networkv1beta2
import models.io.upbound.azure.v1alpha1 as azurev1alpha1
import models.io.upbound.azure.v1beta1 as azurev1beta1
import models.io.upbound.platform.azure.v1alpha1 as platformazurev1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

# observed composite resource
oxr = option("params").oxr
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
# Example to retrieve variables from "xr"; update as needed
# _region = "us-east-1"
# if oxr.spec?.parameters?.region:
#     _region = oxr.spec.parameters.region

# Helper function to add common spec fields
_add_common_spec_fields = lambda spec: any -> any {
    spec | {
        deletionPolicy = params.deletionPolicy
        providerConfigRef.name = params.providerConfigRef
    }
}

_items = [
    # Resource Group
    azurev1beta1.ResourceGroup {
        metadata = _metadata("${params.id}-resourceGroup")
        spec = _add_common_spec_fields(azurev1beta1.AzureUpboundIoV1beta1ResourceGroupSpec {
            forProvider = azurev1beta1.AzureUpboundIoV1beta1ResourceGroupSpecForProvider {
                location = params.region
            }
        })
    }

    # Virtual Network
    networkv1beta2.VirtualNetwork {
        metadata = _metadata("${params.id}-vnet")
        spec = _add_common_spec_fields(networkv1beta2.NetworkAzureUpboundIoV1beta2VirtualNetworkSpec {
            forProvider = networkv1beta2.NetworkAzureUpboundIoV1beta2VirtualNetworkSpecForProvider {
                location = params.region
                addressSpace = ["192.168.0.0/16"]
                resourceGroupNameSelector = {
                    matchControllerRef = True
                }
            }
        })
    }

    # Subnet
    networkv1beta2.Subnet {
        metadata = _metadata("${params.id}-sn")
        spec = _add_common_spec_fields(networkv1beta2.NetworkAzureUpboundIoV1beta2SubnetSpec {
            forProvider = networkv1beta2.NetworkAzureUpboundIoV1beta2SubnetSpecForProvider {
                addressPrefixes = ["192.168.1.0/24"]
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

items = _items
