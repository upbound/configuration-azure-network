import models.io.upbound.platform.azure.v1alpha1 as platformazurev1alpha1
import models.io.upbound.azure.v1beta1 as azurev1beta1
import models.io.upbound.azure.network.v1beta2 as networkv1beta2
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

_items = [
    metav1alpha1.CompositionTest{
        metadata.name = "test-xnetwork"
        spec = {
            assertResources: [
                # The XNetwork composite resource
                platformazurev1alpha1.XNetwork{
                    metadata.name = "ref-azure-network"
                    spec.parameters = {
                        id = "ref-azure-network-from-xr"
                        region = "westus"
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
                        addressSpace = ["192.168.0.0/16"]
                        resourceGroupNameSelector = {
                            matchControllerRef = True
                        }
                    }
                    spec.deletionPolicy = "Delete"
                    spec.providerConfigRef.name = "default"
                }

                # Subnet
                networkv1beta2.Subnet{
                    metadata.name = "ref-azure-network-from-xr-sn"
                    metadata.labels = {
                        "azure.platform.upbound.io/network-id" = "ref-azure-network-from-xr"
                    }
                    spec.forProvider = {
                        addressPrefixes = ["192.168.1.0/24"]
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
