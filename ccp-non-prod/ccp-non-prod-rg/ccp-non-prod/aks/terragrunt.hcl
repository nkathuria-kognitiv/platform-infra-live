# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../..//platform-infrastructure-modules/terraform/modules/azure/aks"

  extra_arguments "custom_vars" {
    commands = [
      "apply",
      "plan",
      "destroy"
    ]
    required_var_files = ["${get_parent_terragrunt_dir()}/common.tfvars"]
  }
}

# Includes all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("common.hcl")
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {

  vnet_name                        = "ccp-non-prod-zonal-virtual-network"

  aks_cluster_name                 = "ccp-nonprod-aks"
  aks_cluster_version              = "1.21.9"
  aks_cluster_acr_name             = "ccpcontainerregistry" #FIX ME
  acr_resource_group_name          = "ccp-non-prod-rg"
  aks_node_pool_subnet_cidr        = "10.1.0.0/17"

  k8s_docker_bridge_cidr           = "172.17.0.1/16"
  k8s_service_cidr                 = "10.0.0.0/16"
  k8s_dns_service_ip               = "10.0.0.10"

  system_node_pool_vm_size         = "Standard_D2as_v4"
  system_pool_node_count           = 1
  system_node_pool_max_pods        = 30

  user_node_pool_vm_size           = "Standard_D2as_v4"
  user_pool_node_count             = 3
  user_node_pool_max_pods          = 30

  enable_node_pool_host_encryption = false 
}
