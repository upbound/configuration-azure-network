from crossplane.function import resource
from crossplane.function.proto.v1 import run_function_pb2 as fnv1
from typing import List, Dict, Any, Optional
from pydantic import BaseModel

# Import XR model
from .model.io.upbound.platform.azure.network import v1alpha1 as networkxr

# Import managed resource models (v2 namespaced)
from .model.io.upbound.m.azure.resourcegroup import v1beta1 as rgv1beta1
from .model.io.upbound.m.azure.network.virtualnetwork import v1beta1 as vnetv1beta1
from .model.io.upbound.m.azure.network.subnet import v1beta1 as subnetv1beta1


# Define ObjectMeta locally to avoid k8s import issues
class ObjectMeta(BaseModel):
    name: str
    namespace: Optional[str] = None
    labels: Optional[Dict[str, str]] = None
    annotations: Optional[Dict[str, str]] = None


def compose(req: fnv1.RunFunctionRequest, rsp: fnv1.RunFunctionResponse):
    """
    Compose Azure Network resources including ResourceGroup, VirtualNetwork, and Subnets.

    This function creates:
    1. Resource Group
    2. Virtual Network with address space
    3. General subnet with service endpoints
    4. Optional database subnets with service-specific delegations
    """
    # REQUIRED for Up CLI v0.43+ - converts protobuf Struct to Python dict
    observed_xr = networkxr.Network(
        **resource.struct_to_dict(req.observed.composite.resource)
    )

    # Extract parameters
    params = observed_xr.spec.parameters
    network_id = params.id
    region = params.region
    address_range = params.addressRange or "10.0.0.0/16"
    general_subnet_range = params.generalSubnetRange or "10.0.1.0/24"
    database_subnets = params.databaseSubnets or []
    management_policies = params.managementPolicies
    provider_config_name = params.providerConfigName

    # Common metadata helper
    def create_metadata(name: str, additional_labels: dict = None) -> ObjectMeta:
        """Create metadata with common labels and annotations."""
        labels = {
            "azure.platform.upbound.io/network-id": network_id
        }
        if additional_labels:
            labels.update(additional_labels)

        return ObjectMeta(
            name=name,
            namespace=observed_xr.metadata.namespace,  # v2: inherit from XR
            labels=labels
        )

    # Common spec helper
    def create_provider_config_ref() -> dict:
        """Create ProviderConfigRef with v2 required fields."""
        return {
            "kind": "ProviderConfig",  # v2: required kind
            "name": provider_config_name
        }

    # 1. Resource Group
    resource_group = rgv1beta1.ResourceGroup(
        apiVersion="azure.m.upbound.io/v1beta1",
        kind="ResourceGroup",
        metadata=create_metadata(f"{network_id}-rg").model_dump(exclude_none=True),
        spec=rgv1beta1.Spec(
            forProvider=rgv1beta1.ForProvider(
                location=region
            ),
            managementPolicies=management_policies,
            providerConfigRef=create_provider_config_ref()
        )
    )
    resource.update(
        rsp.desired.resources[f"{network_id}-rg"],
        resource_group.model_dump(exclude_unset=True, by_alias=True)
    )

    # 2. Virtual Network
    virtual_network = vnetv1beta1.VirtualNetwork(
        apiVersion="network.azure.m.upbound.io/v1beta1",
        kind="VirtualNetwork",
        metadata=create_metadata(f"{network_id}-vnet").model_dump(exclude_none=True),
        spec=vnetv1beta1.Spec(
            forProvider=vnetv1beta1.ForProvider(
                location=region,
                addressSpace=[address_range],
                resourceGroupNameSelector=vnetv1beta1.ResourceGroupNameSelector(
                    matchControllerRef=True
                )
            ),
            managementPolicies=management_policies,
            providerConfigRef=create_provider_config_ref()
        )
    )
    resource.update(
        rsp.desired.resources[f"{network_id}-vnet"],
        virtual_network.model_dump(exclude_unset=True, by_alias=True)
    )

    # 3. General Subnet
    general_subnet = subnetv1beta1.Subnet(
        apiVersion="network.azure.m.upbound.io/v1beta1",
        kind="Subnet",
        metadata=create_metadata(
            f"{network_id}-sn",
            additional_labels={"azure.platform.upbound.io/subnet-service-type": "general"}
        ).model_dump(exclude_none=True),
        spec=subnetv1beta1.Spec(
            forProvider=subnetv1beta1.ForProvider(
                addressPrefixes=[general_subnet_range],
                resourceGroupNameSelector=subnetv1beta1.ResourceGroupNameSelector(
                    matchControllerRef=True
                ),
                serviceEndpoints=["Microsoft.Sql"],
                virtualNetworkNameSelector=subnetv1beta1.VirtualNetworkNameSelector(
                    matchControllerRef=True
                )
            ),
            managementPolicies=management_policies,
            providerConfigRef=create_provider_config_ref()
        )
    )
    resource.update(
        rsp.desired.resources[f"{network_id}-sn"],
        general_subnet.model_dump(exclude_unset=True, by_alias=True)
    )

    # 4. Database Subnets (optional)
    for index, db_subnet in enumerate(database_subnets):
        subnet_name = f"{network_id}-db-sn-{index}"
        service_type = db_subnet.serviceType
        address_range = db_subnet.addressRange

        # Determine delegation based on service type
        delegation_name = (
            "Microsoft.DBforPostgreSQL/flexibleServers"
            if service_type == "postgres"
            else "Microsoft.DBforMySQL/flexibleServers"
        )

        db_subnet_resource = subnetv1beta1.Subnet(
            apiVersion="network.azure.m.upbound.io/v1beta1",
            kind="Subnet",
            metadata=create_metadata(
                subnet_name,
                additional_labels={"azure.platform.upbound.io/subnet-service-type": service_type}
            ).model_dump(exclude_none=True),
            spec=subnetv1beta1.Spec(
                forProvider=subnetv1beta1.ForProvider(
                    addressPrefixes=[address_range],
                    delegation=[
                        subnetv1beta1.DelegationItem(
                            name="fs",
                            serviceDelegation=subnetv1beta1.ServiceDelegation(
                                actions=["Microsoft.Network/virtualNetworks/subnets/join/action"],
                                name=delegation_name
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
                managementPolicies=management_policies,
                providerConfigRef=create_provider_config_ref()
            )
        )
        resource.update(
            rsp.desired.resources[subnet_name],
            db_subnet_resource.model_dump(exclude_unset=True, by_alias=True)
        )
