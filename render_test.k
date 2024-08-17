import file
import yaml

getByCompositeResourceName = lambda name: str -> any {
   render = yaml.decode_all(file.read(".cache/render.yaml"))
   resource = [ el for el in render if el.metadata.annotations?["crossplane.io/composition-resource-name"] == name][0]
   resource
}

test_vnet_name = lambda {
   virtualNetwork = getByCompositeResourceName("virtualNetwork")
   assert virtualNetwork.metadata.name == "ref-azure-network-from-xr-vnet"
}

test_vnet_address = lambda {
   virtualNetwork = getByCompositeResourceName("virtualNetwork")
   assert virtualNetwork.spec.forProvider.addressSpace[0] == "192.168.0.0/16"
}

test_vnet_region = lambda {
   virtualNetwork = getByCompositeResourceName("virtualNetwork")
   assert virtualNetwork.spec.forProvider.location == "westus"
}

test_subnet_svc_endpoints_sql = lambda {
   subnet = getByCompositeResourceName("subnet")
   assert subnet.spec.forProvider.serviceEndpoints[0] == "Microsoft.Sql"
}
