# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../../../..//platform-infra-modules/terraform/modules/azure/apis/communication/v1" #fix this path as necessary

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

dependency "communication_product" {
  config_path = "../../../products/communication"
}

dependency "versionset" {
  config_path = "../"
  skip_outputs = true
}

# Includes all settings from the root terragrunt.hcl file
include {
  path = find_in_parent_folders("common.hcl")
}

# These are the variables we have to pass in to use the module specified in the terragrunt configuration above
inputs = {
  post_email_schema_id = "1656011310869" #This is created manually from the portal. this is done so that changes done manually are not lost.
  post_email_type_name = "postCommunication"
}
