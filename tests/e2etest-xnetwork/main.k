import models.io.upbound.platform.azure.v1alpha1 as platformazurev1alpha1
import models.io.upbound.azure.v1beta1 as azurev1beta1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import file

_items = [
    metav1alpha1.E2ETest{
        metadata.name = "e2etest-xnetwork-azure"
        spec = {
            # Configure Crossplane for the test environment
            crossplane.autoUpgrade.channel = "Rapid"

            # Define the conditions that indicate successful resource creation
            defaultConditions = [
                "Ready"
            ]

            # Define the resource to be created
            manifests = [
                platformazurev1alpha1.XNetwork{
                    metadata.name = "uptest-azure-network"
                    spec.parameters = {
                        id = "uptest-azure-network"
                        region = "westus2"
                        deletionPolicy = "Delete"
                        providerConfigName = "default"
                    }
                }
            ]

            # Define the provider configuration
            extraResources = [
                azurev1beta1.ProviderConfig{
                    metadata.name = "default"
                    spec = {
                        credentials = {
                            source = "Upbound"
                        }
                        clientID = "bcf40abd-283c-494b-b186-03d6c864be51"
                        tenantID = "b9925bc4-8383-4c37-b9d2-fa456d1bb1c7"
                        subscriptionID = "038f2b7c-3265-43b8-8624-c9ad5da610a8"
                    }
                }

            ]

            # Test cleanup settings
            skipDelete = False

            # Set a reasonable timeout for resources to be provisioned
            timeoutSeconds = 3600
        }
    }
]

items = _items
