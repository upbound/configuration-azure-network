import models.io.upbound.platform.azure.v1alpha1 as platformazurev1alpha1
import models.io.upbound.azure.v1beta1 as azurev1beta1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1

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
                    spec.credentials = {
                        source = "Secret"
                        secretRef = {
                            namespace = "crossplane-system"
                            name = "azure-secret"
                            key = "creds"
                        }
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
