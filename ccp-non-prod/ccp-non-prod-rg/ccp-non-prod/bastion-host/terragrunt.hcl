# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../..//platform-infrastructure-modules/terraform/modules/azure/bastion-host"

  extra_arguments "custom_vars" {
    commands = [
      "apply",
      "plan",
      "destroy"
    ]
    required_var_files = ["${get_parent_terragrunt_dir()}/common.tfvars"]
  }
}

# Includes all settings from the common.hcl file
include {
  path = find_in_parent_folders("common.hcl")
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  vnet_name               = "ccp-non-prod-zonal-virtual-network"
  subnet_name             = "public-zone1-ccp-non-prod-zonal-virtual-network"
  resource_group_name     = "ccp-non-prod-rg"
  location                = "eastus"
  vm_size                 = "Standard_B2s"
  key_vault_name          = "ccp-non-prod-kv"

  skip_bootstrap          = true

  # list of ip addresses for ssh access to the bastion server
  # Chris's IP, La Plata VPN address
  ssh_source_address_list = ["75.73.114.22/32","54.232.165.254/32"]
}
