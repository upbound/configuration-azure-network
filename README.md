# Azure Network Configuration

This repository contains a [Crossplane configuration](https://docs.crossplane.io/v1.11/concepts/packages/#configuration-packages), tailored for users establishing their initial control plane with [Upbound](https://cloud.upbound.io). This configuration deploys fully managed [Azure network]().

## Overview

The core components of a custom API in [Crossplane](https://docs.crossplane.io/v1.11/getting-started/introduction/) include:

- **CompositeResourceDefinition (XRD):** Defines the API's structure.
- **Composition(s):** Implements the API by orchestrating a set of Crossplane managed resources.

In this specific configuration, the [] API contains:

- **an [Azure Network](/apis/definition.yaml) custom resource type.**
- **Composition of the network resources:** Configured in [/apis/composition.yaml](/apis/composition.yaml), it provisions fundamental security and networking resources in the `upbound-system` namespace.

This repository contains an Composite Resource (XR) file.

## Deployment

```shell
apiVersion: pkg.crossplane.io/v1
kind: Configuration
metadata:
  name: configuration-azure-network
spec:
  package: xpkg.upbound.io/upbound/configuration-azure-network:v0.4.0
```

## Next steps

This repository serves as a foundational step. To enhance your control plane, consider:

1. create new API definitions in this same repo
2. editing the existing API definition to your needs


Upbound will automatically detect the commits you make in your repo and build the configuration package for you. To learn more about how to build APIs for your managed control planes in Upbound, read the guide on Upbound's docs.
