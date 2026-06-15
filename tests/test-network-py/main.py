from .model.io.upbound.dev.meta.compositiontest import v1alpha1 as compositiontest
from .model.io.k8s.apimachinery.pkg.apis.meta import v1 as k8s
from .model.io.upbound.platform.azure.network import v1alpha1 as networkxr
from .model.io.upbound.m.azure.resourcegroup import v1beta1 as rgv1beta1
from .model.io.upbound.m.azure.network.virtualnetwork import v1beta1 as vnetv1beta1
from .model.io.upbound.m.azure.network.subnet import v1beta1 as subnetv1beta1

# Test 1: Network with PostgreSQL database subnet
test_network_with_postgresql_db = compositiontest.CompositionTest(
    metadata=k8s.ObjectMeta(
        name="test-network-with-postgresql-db",
    ),
    spec=compositiontest.Spec(
        assertResources=[
            # The Network composite resource
            networkxr.Network(
                apiVersion="azure.platform.upbound.io/v1alpha1",
                kind="Network",
                metadata=k8s.ObjectMeta(name="ref-azure-network"),
                spec=networkxr.Spec(
                    parameters=networkxr.Parameters(
                        id="ref-azure-network-from-xr",
                        region="westus",
                        addressRange="10.0.0.0/16",
                        generalSubnetRange="10.0.1.0/24",
                        databaseSubnets=[
                            networkxr.DatabaseSubnet(
                                addressRange="10.0.2.0/24",
                                serviceType="postgres"
                            )
                        ],
                        managementPolicies=["*"],
                        providerConfigName="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True),

            # Resource Group
            rgv1beta1.ResourceGroup(
                apiVersion="azure.m.upbound.io/v1beta1",
                kind="ResourceGroup",
                metadata=k8s.ObjectMeta(
                    name="ref-azure-network-from-xr-rg",
                    labels={
                        "azure.platform.upbound.io/network-id": "ref-azure-network-from-xr"
                    }
                ),
                spec=rgv1beta1.Spec(
                    forProvider=rgv1beta1.ForProvider(
                        location="westus"
                    ),
                    managementPolicies=["*"],
                    providerConfigRef=rgv1beta1.ProviderConfigRef(
                        kind="ProviderConfig",
                        name="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True),

            # Virtual Network
            vnetv1beta1.VirtualNetwork(
                apiVersion="network.azure.m.upbound.io/v1beta1",
                kind="VirtualNetwork",
                metadata=k8s.ObjectMeta(
                    name="ref-azure-network-from-xr-vnet",
                    labels={
                        "azure.platform.upbound.io/network-id": "ref-azure-network-from-xr"
                    }
                ),
                spec=vnetv1beta1.Spec(
                    forProvider=vnetv1beta1.ForProvider(
                        location="westus",
                        addressSpace=["10.0.0.0/16"],
                        resourceGroupNameSelector=vnetv1beta1.ResourceGroupNameSelector(
                            matchControllerRef=True
                        )
                    ),
                    managementPolicies=["*"],
                    providerConfigRef=vnetv1beta1.ProviderConfigRef(
                        kind="ProviderConfig",
                        name="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True),

            # General Subnet
            subnetv1beta1.Subnet(
                apiVersion="network.azure.m.upbound.io/v1beta1",
                kind="Subnet",
                metadata=k8s.ObjectMeta(
                    name="ref-azure-network-from-xr-sn",
                    labels={
                        "azure.platform.upbound.io/network-id": "ref-azure-network-from-xr",
                        "azure.platform.upbound.io/subnet-service-type": "general"
                    }
                ),
                spec=subnetv1beta1.Spec(
                    forProvider=subnetv1beta1.ForProvider(
                        addressPrefixes=["10.0.1.0/24"],
                        resourceGroupNameSelector=subnetv1beta1.ResourceGroupNameSelector(
                            matchControllerRef=True
                        ),
                        serviceEndpoints=["Microsoft.Sql"],
                        virtualNetworkNameSelector=subnetv1beta1.VirtualNetworkNameSelector(
                            matchControllerRef=True
                        )
                    ),
                    managementPolicies=["*"],
                    providerConfigRef=subnetv1beta1.ProviderConfigRef(
                        kind="ProviderConfig",
                        name="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True),

            # Database Subnet with PostgreSQL delegation
            subnetv1beta1.Subnet(
                apiVersion="network.azure.m.upbound.io/v1beta1",
                kind="Subnet",
                metadata=k8s.ObjectMeta(
                    name="ref-azure-network-from-xr-db-sn-0",
                    labels={
                        "azure.platform.upbound.io/network-id": "ref-azure-network-from-xr",
                        "azure.platform.upbound.io/subnet-service-type": "postgres"
                    }
                ),
                spec=subnetv1beta1.Spec(
                    forProvider=subnetv1beta1.ForProvider(
                        addressPrefixes=["10.0.2.0/24"],
                        delegation=[
                            subnetv1beta1.DelegationItem(
                                name="fs",
                                serviceDelegation=subnetv1beta1.ServiceDelegation(
                                    actions=["Microsoft.Network/virtualNetworks/subnets/join/action"],
                                    name="Microsoft.DBforPostgreSQL/flexibleServers"
                                )
                            )
                        ],
                        resourceGroupNameSelector=subnetv1beta1.ResourceGroupNameSelector(
                            matchControllerRef=True
                        ),
                        serviceEndpoints=["Microsoft.Storage"],
                        virtualNetworkNameSelector=subnetv1beta1.VirtualNetworkNameSelector(
                            matchControllerRef=True
                        )
                    ),
                    managementPolicies=["*"],
                    providerConfigRef=subnetv1beta1.ProviderConfigRef(
                        kind="ProviderConfig",
                        name="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True)
        ],
        compositionPath="apis/networks/composition.yaml",
        xrPath="examples/network-xr-with-pg-db.yaml",
        xrdPath="apis/networks/definition.yaml",
        timeoutSeconds=120,
        validate=False
    )
)

# Test 2: Network with MySQL database subnet
test_network_with_mysql_db = compositiontest.CompositionTest(
    metadata=k8s.ObjectMeta(
        name="test-network-with-mysql-db",
    ),
    spec=compositiontest.Spec(
        assertResources=[
            # The Network composite resource
            networkxr.Network(
                apiVersion="azure.platform.upbound.io/v1alpha1",
                kind="Network",
                metadata=k8s.ObjectMeta(name="ref-azure-network"),
                spec=networkxr.Spec(
                    parameters=networkxr.Parameters(
                        id="ref-azure-network-from-xr",
                        region="westus",
                        addressRange="10.0.0.0/16",
                        generalSubnetRange="10.0.1.0/24",
                        databaseSubnets=[
                            networkxr.DatabaseSubnet(
                                addressRange="10.0.2.0/24",
                                serviceType="mysql"
                            )
                        ],
                        managementPolicies=["*"],
                        providerConfigName="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True),

            # Resource Group
            rgv1beta1.ResourceGroup(
                apiVersion="azure.m.upbound.io/v1beta1",
                kind="ResourceGroup",
                metadata=k8s.ObjectMeta(
                    name="ref-azure-network-from-xr-rg",
                    labels={
                        "azure.platform.upbound.io/network-id": "ref-azure-network-from-xr"
                    }
                ),
                spec=rgv1beta1.Spec(
                    forProvider=rgv1beta1.ForProvider(
                        location="westus"
                    ),
                    managementPolicies=["*"],
                    providerConfigRef=rgv1beta1.ProviderConfigRef(
                        kind="ProviderConfig",
                        name="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True),

            # Virtual Network
            vnetv1beta1.VirtualNetwork(
                apiVersion="network.azure.m.upbound.io/v1beta1",
                kind="VirtualNetwork",
                metadata=k8s.ObjectMeta(
                    name="ref-azure-network-from-xr-vnet",
                    labels={
                        "azure.platform.upbound.io/network-id": "ref-azure-network-from-xr"
                    }
                ),
                spec=vnetv1beta1.Spec(
                    forProvider=vnetv1beta1.ForProvider(
                        location="westus",
                        addressSpace=["10.0.0.0/16"],
                        resourceGroupNameSelector=vnetv1beta1.ResourceGroupNameSelector(
                            matchControllerRef=True
                        )
                    ),
                    managementPolicies=["*"],
                    providerConfigRef=vnetv1beta1.ProviderConfigRef(
                        kind="ProviderConfig",
                        name="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True),

            # General Subnet
            subnetv1beta1.Subnet(
                apiVersion="network.azure.m.upbound.io/v1beta1",
                kind="Subnet",
                metadata=k8s.ObjectMeta(
                    name="ref-azure-network-from-xr-sn",
                    labels={
                        "azure.platform.upbound.io/network-id": "ref-azure-network-from-xr",
                        "azure.platform.upbound.io/subnet-service-type": "general"
                    }
                ),
                spec=subnetv1beta1.Spec(
                    forProvider=subnetv1beta1.ForProvider(
                        addressPrefixes=["10.0.1.0/24"],
                        resourceGroupNameSelector=subnetv1beta1.ResourceGroupNameSelector(
                            matchControllerRef=True
                        ),
                        serviceEndpoints=["Microsoft.Sql"],
                        virtualNetworkNameSelector=subnetv1beta1.VirtualNetworkNameSelector(
                            matchControllerRef=True
                        )
                    ),
                    managementPolicies=["*"],
                    providerConfigRef=subnetv1beta1.ProviderConfigRef(
                        kind="ProviderConfig",
                        name="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True),

            # Database Subnet with MySQL delegation
            subnetv1beta1.Subnet(
                apiVersion="network.azure.m.upbound.io/v1beta1",
                kind="Subnet",
                metadata=k8s.ObjectMeta(
                    name="ref-azure-network-from-xr-db-sn-0",
                    labels={
                        "azure.platform.upbound.io/network-id": "ref-azure-network-from-xr",
                        "azure.platform.upbound.io/subnet-service-type": "mysql"
                    }
                ),
                spec=subnetv1beta1.Spec(
                    forProvider=subnetv1beta1.ForProvider(
                        addressPrefixes=["10.0.2.0/24"],
                        delegation=[
                            subnetv1beta1.DelegationItem(
                                name="fs",
                                serviceDelegation=subnetv1beta1.ServiceDelegation(
                                    actions=["Microsoft.Network/virtualNetworks/subnets/join/action"],
                                    name="Microsoft.DBforMySQL/flexibleServers"
                                )
                            )
                        ],
                        resourceGroupNameSelector=subnetv1beta1.ResourceGroupNameSelector(
                            matchControllerRef=True
                        ),
                        serviceEndpoints=["Microsoft.Storage"],
                        virtualNetworkNameSelector=subnetv1beta1.VirtualNetworkNameSelector(
                            matchControllerRef=True
                        )
                    ),
                    managementPolicies=["*"],
                    providerConfigRef=subnetv1beta1.ProviderConfigRef(
                        kind="ProviderConfig",
                        name="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True)
        ],
        compositionPath="apis/networks/composition.yaml",
        xrPath="examples/network-xr-with-mysql-db.yaml",
        xrdPath="apis/networks/definition.yaml",
        timeoutSeconds=120,
        validate=False
    )
)

# Test 3: Network without database subnets
test_network_without_db = compositiontest.CompositionTest(
    metadata=k8s.ObjectMeta(
        name="test-network-without-db",
    ),
    spec=compositiontest.Spec(
        assertResources=[
            # The Network composite resource
            networkxr.Network(
                apiVersion="azure.platform.upbound.io/v1alpha1",
                kind="Network",
                metadata=k8s.ObjectMeta(name="ref-azure-network"),
                spec=networkxr.Spec(
                    parameters=networkxr.Parameters(
                        id="ref-azure-network-from-xr",
                        region="westus",
                        addressRange="10.0.0.0/16",
                        generalSubnetRange="10.0.1.0/24",
                        managementPolicies=["*"],
                        providerConfigName="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True),

            # Resource Group
            rgv1beta1.ResourceGroup(
                apiVersion="azure.m.upbound.io/v1beta1",
                kind="ResourceGroup",
                metadata=k8s.ObjectMeta(
                    name="ref-azure-network-from-xr-rg",
                    labels={
                        "azure.platform.upbound.io/network-id": "ref-azure-network-from-xr"
                    }
                ),
                spec=rgv1beta1.Spec(
                    forProvider=rgv1beta1.ForProvider(
                        location="westus"
                    ),
                    managementPolicies=["*"],
                    providerConfigRef=rgv1beta1.ProviderConfigRef(
                        kind="ProviderConfig",
                        name="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True),

            # Virtual Network
            vnetv1beta1.VirtualNetwork(
                apiVersion="network.azure.m.upbound.io/v1beta1",
                kind="VirtualNetwork",
                metadata=k8s.ObjectMeta(
                    name="ref-azure-network-from-xr-vnet",
                    labels={
                        "azure.platform.upbound.io/network-id": "ref-azure-network-from-xr"
                    }
                ),
                spec=vnetv1beta1.Spec(
                    forProvider=vnetv1beta1.ForProvider(
                        location="westus",
                        addressSpace=["10.0.0.0/16"],
                        resourceGroupNameSelector=vnetv1beta1.ResourceGroupNameSelector(
                            matchControllerRef=True
                        )
                    ),
                    managementPolicies=["*"],
                    providerConfigRef=vnetv1beta1.ProviderConfigRef(
                        kind="ProviderConfig",
                        name="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True),

            # General Subnet
            subnetv1beta1.Subnet(
                apiVersion="network.azure.m.upbound.io/v1beta1",
                kind="Subnet",
                metadata=k8s.ObjectMeta(
                    name="ref-azure-network-from-xr-sn",
                    labels={
                        "azure.platform.upbound.io/network-id": "ref-azure-network-from-xr",
                    }
                ),
                spec=subnetv1beta1.Spec(
                    forProvider=subnetv1beta1.ForProvider(
                        addressPrefixes=["10.0.1.0/24"],
                        resourceGroupNameSelector=subnetv1beta1.ResourceGroupNameSelector(
                            matchControllerRef=True
                        ),
                        serviceEndpoints=["Microsoft.Sql"],
                        virtualNetworkNameSelector=subnetv1beta1.VirtualNetworkNameSelector(
                            matchControllerRef=True
                        )
                    ),
                    managementPolicies=["*"],
                    providerConfigRef=subnetv1beta1.ProviderConfigRef(
                        kind="ProviderConfig",
                        name="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True)
        ],
        compositionPath="apis/networks/composition.yaml",
        xrPath="examples/network-xr.yaml",
        xrdPath="apis/networks/definition.yaml",
        timeoutSeconds=120,
        validate=False
    )
)

# Test 4: Network with multiple database subnets
test_network_with_multiple_dbs = compositiontest.CompositionTest(
    metadata=k8s.ObjectMeta(
        name="test-network-with-multiple-dbs",
    ),
    spec=compositiontest.Spec(
        assertResources=[
            # The Network composite resource
            networkxr.Network(
                apiVersion="azure.platform.upbound.io/v1alpha1",
                kind="Network",
                metadata=k8s.ObjectMeta(name="ref-azure-network"),
                spec=networkxr.Spec(
                    parameters=networkxr.Parameters(
                        id="ref-azure-network-from-xr",
                        region="westus",
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
            ).model_dump(exclude_unset=True, by_alias=True),

            # Resource Group
            rgv1beta1.ResourceGroup(
                apiVersion="azure.m.upbound.io/v1beta1",
                kind="ResourceGroup",
                metadata=k8s.ObjectMeta(
                    name="ref-azure-network-from-xr-rg",
                    labels={
                        "azure.platform.upbound.io/network-id": "ref-azure-network-from-xr"
                    }
                ),
                spec=rgv1beta1.Spec(
                    forProvider=rgv1beta1.ForProvider(
                        location="westus"
                    ),
                    managementPolicies=["*"],
                    providerConfigRef=rgv1beta1.ProviderConfigRef(
                        kind="ProviderConfig",
                        name="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True),

            # Virtual Network
            vnetv1beta1.VirtualNetwork(
                apiVersion="network.azure.m.upbound.io/v1beta1",
                kind="VirtualNetwork",
                metadata=k8s.ObjectMeta(
                    name="ref-azure-network-from-xr-vnet",
                    labels={
                        "azure.platform.upbound.io/network-id": "ref-azure-network-from-xr"
                    }
                ),
                spec=vnetv1beta1.Spec(
                    forProvider=vnetv1beta1.ForProvider(
                        location="westus",
                        addressSpace=["10.0.0.0/16"],
                        resourceGroupNameSelector=vnetv1beta1.ResourceGroupNameSelector(
                            matchControllerRef=True
                        )
                    ),
                    managementPolicies=["*"],
                    providerConfigRef=vnetv1beta1.ProviderConfigRef(
                        kind="ProviderConfig",
                        name="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True),

            # General Subnet
            subnetv1beta1.Subnet(
                apiVersion="network.azure.m.upbound.io/v1beta1",
                kind="Subnet",
                metadata=k8s.ObjectMeta(
                    name="ref-azure-network-from-xr-sn",
                    labels={
                        "azure.platform.upbound.io/network-id": "ref-azure-network-from-xr",
                    }
                ),
                spec=subnetv1beta1.Spec(
                    forProvider=subnetv1beta1.ForProvider(
                        addressPrefixes=["10.0.1.0/24"],
                        resourceGroupNameSelector=subnetv1beta1.ResourceGroupNameSelector(
                            matchControllerRef=True
                        ),
                        serviceEndpoints=["Microsoft.Sql"],
                        virtualNetworkNameSelector=subnetv1beta1.VirtualNetworkNameSelector(
                            matchControllerRef=True
                        )
                    ),
                    managementPolicies=["*"],
                    providerConfigRef=subnetv1beta1.ProviderConfigRef(
                        kind="ProviderConfig",
                        name="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True),

            # Database Subnet with PostgreSQL delegation
            subnetv1beta1.Subnet(
                apiVersion="network.azure.m.upbound.io/v1beta1",
                kind="Subnet",
                metadata=k8s.ObjectMeta(
                    name="ref-azure-network-from-xr-db-sn-0",
                    labels={
                        "azure.platform.upbound.io/network-id": "ref-azure-network-from-xr",
                        "azure.platform.upbound.io/subnet-service-type": "postgres"
                    }
                ),
                spec=subnetv1beta1.Spec(
                    forProvider=subnetv1beta1.ForProvider(
                        addressPrefixes=["10.0.2.0/24"],
                        delegation=[
                            subnetv1beta1.DelegationItem(
                                name="fs",
                                serviceDelegation=subnetv1beta1.ServiceDelegation(
                                    actions=["Microsoft.Network/virtualNetworks/subnets/join/action"],
                                    name="Microsoft.DBforPostgreSQL/flexibleServers"
                                )
                            )
                        ],
                        resourceGroupNameSelector=subnetv1beta1.ResourceGroupNameSelector(
                            matchControllerRef=True
                        ),
                        serviceEndpoints=["Microsoft.Storage"],
                        virtualNetworkNameSelector=subnetv1beta1.VirtualNetworkNameSelector(
                            matchControllerRef=True
                        )
                    ),
                    managementPolicies=["*"],
                    providerConfigRef=subnetv1beta1.ProviderConfigRef(
                        kind="ProviderConfig",
                        name="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True),

            # Database Subnet with MySQL delegation
            subnetv1beta1.Subnet(
                apiVersion="network.azure.m.upbound.io/v1beta1",
                kind="Subnet",
                metadata=k8s.ObjectMeta(
                    name="ref-azure-network-from-xr-db-sn-1",
                    labels={
                        "azure.platform.upbound.io/network-id": "ref-azure-network-from-xr",
                        "azure.platform.upbound.io/subnet-service-type": "mysql"
                    }
                ),
                spec=subnetv1beta1.Spec(
                    forProvider=subnetv1beta1.ForProvider(
                        addressPrefixes=["10.0.3.0/24"],
                        delegation=[
                            subnetv1beta1.DelegationItem(
                                name="fs",
                                serviceDelegation=subnetv1beta1.ServiceDelegation(
                                    actions=["Microsoft.Network/virtualNetworks/subnets/join/action"],
                                    name="Microsoft.DBforMySQL/flexibleServers"
                                )
                            )
                        ],
                        resourceGroupNameSelector=subnetv1beta1.ResourceGroupNameSelector(
                            matchControllerRef=True
                        ),
                        serviceEndpoints=["Microsoft.Storage"],
                        virtualNetworkNameSelector=subnetv1beta1.VirtualNetworkNameSelector(
                            matchControllerRef=True
                        )
                    ),
                    managementPolicies=["*"],
                    providerConfigRef=subnetv1beta1.ProviderConfigRef(
                        kind="ProviderConfig",
                        name="default"
                    )
                )
            ).model_dump(exclude_unset=True, by_alias=True)
        ],
        compositionPath="apis/networks/composition.yaml",
        xrPath="examples/network-xr-with-multiple-dbs.yaml",
        xrdPath="apis/networks/definition.yaml",
        timeoutSeconds=120,
        validate=False
    )
)
