# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../..//platform-infrastructure-modules/terraform/modules/azure/zonal-virtual-network" #fix this path as necessary

  extra_arguments "custom_vars" {
    commands = [
      "apply",
      "plan",
      "destroy"
    ]
    arguments = ["-parallelism=1"]
    required_var_files = ["${get_parent_terragrunt_dir()}/common.tfvars"]
  }
}

# Includes all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("common.hcl")
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  address_space = "10.1.0.0/16"

  privatesubnetaddress1 = "10.1.201.0/24"
  privatesubnetaddress2 = "10.1.202.0/24"
  privatesubnetaddress3 = "10.1.203.0/24"

  publicsubnetaddress1 = "10.1.240.0/24"
  publicsubnetaddress2 = "10.1.241.0/24"
  publicsubnetaddress3 = "10.1.242.0/24"

  launch_vnet_bastion_server = false
}
