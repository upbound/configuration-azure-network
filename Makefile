# Usage
# ====================================================================================
# Generic Makefile to be used across repositories building a crossplane configuration
# package
#
# Available targets:
#
# - `yamllint`
#   Runs yamllint for all files in `api`-folder recursively
#
# - `render`
#   Runs crossplane render to render the output of the composition. Usefule for quick
#   feedback in order to test templating.
#   Important note:
#		Claims need following annotations in order for render to work (adjust the paths
#		if necessary):
#			render.crossplane.io/composition-path: apis/pat/composition.yaml
#			render.crossplane.io/function-path: examples/functions.yaml
#
# - `e2e`
#   Runs full end-to-end test, including creating cluster, setting up the configuration
#   and testing if create, import and delete work as expected.
#   This target requires the following environment variables to be set:
#   UPTEST_CLOUD_CREDENTIALS, cloud credentials for the provider being tested, e.g. export UPTEST_CLOUD_CREDENTIALS=$(cat ~/.azure/credentials.json)
#	Available options:
#		UPTEST_SKIP_DELETE (default `false`) skips the deletion of any resources created during the test
#		UPTEST_SKIP_UPDATE (default `false`) skips testing the update of the claims
#		UPTEST_SKIP_IMPORT (default `true`) skips testing the import of resources
#	Example:
#		`make e2e UPTEST_SKIP_DELETE=true`

# Project Setup
# ====================================================================================

# Include project.mk for project specific settings
include project.mk

ifndef PROJECT_NAME
  $(error PROJECT_NAME is not set. Please create `project.mk` and set it there.)
endif

PROJECT_REPO := github.com/upbound/$(PROJECT_NAME)


# NOTE(hasheddan): the platform is insignificant here as Configuration package
# images are not architecture-specific. We constrain to one platform to avoid
# needlessly pushing a multi-arch image.
PLATFORMS ?= linux_amd64
-include build/makelib/common.mk

# ====================================================================================
# Setup Kubernetes tools

UP_VERSION = v0.34.2
UP_CHANNEL = stable
CROSSPLANE_CLI_VERSION = v1.17.1

-include build/makelib/k8s_tools.mk
# ====================================================================================
# Setup XPKG
XPKG_DIR = $(shell pwd)
XPKG_IGNORE = .github/workflows/*.yaml,.github/workflows/*.yml,examples/*.yaml,.work/uptest-datasource.yaml,.cache/*.yaml
XPKG_REG_ORGS ?= xpkg.upbound.io/upbound
# NOTE(hasheddan): skip promoting on xpkg.upbound.io as channel tags are
# inferred.
XPKG_REG_ORGS_NO_PROMOTE ?= xpkg.upbound.io/upbound
XPKGS = $(PROJECT_NAME)
-include build/makelib/xpkg.mk

CROSSPLANE_VERSION = 1.17.1-up.1
CROSSPLANE_CHART_REPO = https://charts.upbound.io/stable
CROSSPLANE_CHART_NAME = universal-crossplane
CROSSPLANE_NAMESPACE = upbound-system
KIND_CLUSTER_NAME = uptest-$(PROJECT_NAME)
-include build/makelib/local.xpkg.mk
-include build/makelib/controlplane.mk

# ====================================================================================
# Testing

UPTEST_VERSION = v1.2.0
UPTEST_LOCAL_DEPLOY_TARGET = local.xpkg.deploy.configuration.$(PROJECT_NAME)
UPTEST_DEFAULT_TIMEOUT = 2400s

-include build/makelib/uptest.mk

# ====================================================================================
# Targets

# run `make help` to see the targets and options

# We want submodules to be set up the first time `make` is run.
# We manage the build/ folder and its Makefiles as a submodule.
# The first time `make` is run, the includes of build/*.mk files will
# all fail, and this target will be run. The next time, the default as defined
# by the includes will be run instead.
fallthrough: submodules
	@echo Initial setup complete. Running make again . . .
	@make

submodules: ## Update the submodules, such as the common build scripts.
	@git submodule sync
	@git submodule update --init --recursive

# We must ensure up is installed in tool cache prior to build as including the k8s_tools machinery prior to the xpkg
# machinery sets UP to point to tool cache.
build.init: $(UP)

render.test: $(CROSSPLANE_CLI) $(KCL)
	$(CROSSPLANE_CLI) render examples/network-xr.yaml apis/pat/composition.yaml examples/functions.yaml -r > ./.cache/render.yaml
	$(KCL) test

help.local:
	@grep -E '^[a-zA-Z_-]+.*:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: uptest e2e render yamllint help.local
