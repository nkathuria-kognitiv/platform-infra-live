# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../..//platform-infra-modules/terraform/modules/azure/apim" #fix this path as necessary

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
  rsg_name = "ccp-qa-apim"
  #apim_name = "qa-kognitiv-apim-gateway"
  apim_sku = "Developer_1"
  storageaccountname = "ccpqaapim"
  containername = "client-programs"
  keyvaultname = "ccp-shared-services-kv"
  keyvault_rsg_name="shared-services"
  certificate_name = "internal-kognitiv-cert"
  api_key_name = "ln-uat-x-api-key"
  certificate_name = "internal-kognitiv"
  custom_domain_host_name = "qa-api.internal-kognitiv.com"
}
