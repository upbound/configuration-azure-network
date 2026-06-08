from .model.io.upbound.dev.meta.e2etest import v1alpha1 as e2etest
from .model.io.k8s.apimachinery.pkg.apis.meta import v1 as k8s
from .model.io.upbound.platform.azure.network import v1alpha1 as networkxr
from .model.io.upbound.m.azure.providerconfig import v1beta1 as providerconfig

# Test 1: Basic network without database subnets
network_azure = e2etest.E2ETest(
    metadata=k8s.ObjectMeta(
        name="network-azure",
    ),
    spec=e2etest.Spec(
        crossplane=e2etest.Crossplane(
            version="2.0.2-up.5",
            autoUpgrade=e2etest.AutoUpgrade(
                channel="Rapid",
            ),
        ),
        defaultConditions=[
            "Ready",
        ],
        manifests=[
            networkxr.Network(
                apiVersion="azure.platform.upbound.io/v1alpha1",
                kind="Network",
                metadata=k8s.ObjectMeta(
                    name="uptest-azure-network",
                    namespace="default"
                ),
                spec=networkxr.Spec(
                    parameters=networkxr.Parameters(
                        id="uptest-azure-network",
                        region="westus2",
                        addressRange="10.0.0.0/16",
                        generalSubnetRange="10.0.1.0/24",
                        managementPolicies=["*"],
                        providerConfigName="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True)
        ],
        extraResources=[
            providerconfig.ProviderConfig(
                apiVersion="azure.m.upbound.io/v1beta1",
                kind="ProviderConfig",
                metadata=k8s.ObjectMeta(
                    name="default",
                    namespace="default"
                ),
                spec=providerconfig.Spec(
                    credentials=providerconfig.Credentials(
                        source="Upbound"
                    ),
                    clientID="bcf40abd-283c-494b-b186-03d6c864be51",
                    tenantID="b9925bc4-8383-4c37-b9d2-fa456d1bb1c7",
                    subscriptionID="038f2b7c-3265-43b8-8624-c9ad5da610a8"
                )
            ).model_dump(exclude_unset=True, by_alias=True)
        ],
        skipDelete=False,
        timeoutSeconds=3600
    )
)

# Test 2: Network with multiple database subnets
network_azure_with_dbs = e2etest.E2ETest(
    metadata=k8s.ObjectMeta(
        name="network-azure-with-dbs",
    ),
    spec=e2etest.Spec(
        crossplane=e2etest.Crossplane(
            version="2.0.2-up.5",
            autoUpgrade=e2etest.AutoUpgrade(
                channel="Rapid",
            ),
        ),
        defaultConditions=[
            "Ready",
        ],
        manifests=[
            networkxr.Network(
                apiVersion="azure.platform.upbound.io/v1alpha1",
                kind="Network",
                metadata=k8s.ObjectMeta(
                    name="uptest-azure-network-with-dbs",
                    namespace="default"
                ),
                spec=networkxr.Spec(
                    parameters=networkxr.Parameters(
                        id="uptest-azure-network-with-dbs",
                        region="westus2",
                        addressRange="10.0.0.0/16",
                        generalSubnetRange="10.0.1.0/24",
                        databaseSubnets=[
                            networkxr.DatabaseSubnet(
                                addressRange="10.0.2.0/24",
                                serviceType="postgres"
                            ),
                            networkxr.DatabaseSubnet(
                                addressRange="10.0.3.0/24",
                                serviceType="mysql"
                            )
                        ],
                        managementPolicies=["*"],
                        providerConfigName="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True)
        ],
        extraResources=[
            providerconfig.ProviderConfig(
                apiVersion="azure.m.upbound.io/v1beta1",
                kind="ProviderConfig",
                metadata=k8s.ObjectMeta(
                    name="default",
                    namespace="default"
                ),
                spec=providerconfig.Spec(
                    credentials=providerconfig.Credentials(
                        source="Upbound"
                    ),
                    clientID="bcf40abd-283c-494b-b186-03d6c864be51",
                    tenantID="b9925bc4-8383-4c37-b9d2-fa456d1bb1c7",
                    subscriptionID="038f2b7c-3265-43b8-8624-c9ad5da610a8"
                )
            ).model_dump(exclude_unset=True, by_alias=True)
        ],
        skipDelete=False,
        timeoutSeconds=3600
    )
)
