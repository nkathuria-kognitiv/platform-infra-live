# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# Global PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

#Set global variables sourced via this config file
locals {

########################################################################
# WARNING!!!!
# Never set this variable to true unless you are developing against terraform code locally and
# do not want to tag an unstable version. 
# When applying to actual environment, this should always be set as false.

  skip_hooks_scripts = "true"


# Before and after hook script location
  before_hook_script_path = find_in_parent_folders("before-hook.sh")
  after_hook_script_path = find_in_parent_folders("after-hook.sh")

# Global variables applied to all code running under terragrunt
  global_yaml_path = find_in_parent_folders("global.yaml")

# Path for release version file stored as tfvars
  release_version_path = find_in_parent_folders("common.hcl")


# Configure Terragrunt to use common vars encoded as yaml to help you keep often-repeated variables (e.g., subscription id, tenant id)
 # DRY. We use yamldecode to merge the maps into the inputs, as opposed to using varfiles due to a restriction in
  # Terraform >=0.12 that all vars must be defined as variable blocks in modules. Terragrunt inputs are not affected by
  # this restriction.
  
  role_vars = yamldecode(
                file("${get_terragrunt_dir()}/role.yaml")
            )
  env_vars = yamldecode(
                file("${find_in_parent_folders("env.yaml", local.global_yaml_path)}")
            )
  subscription_vars = yamldecode(
                file("${find_in_parent_folders("subscription.yaml", local.global_yaml_path)}")
            )
  global_vars = yamldecode(
                file("${find_in_parent_folders("global.yaml", local.global_yaml_path)}")
            )
  version_vars = yamldecode(
                file("${find_in_parent_folders("version.yaml", local.global_yaml_path)}")
            )
  resource_group_vars = yamldecode(
                file("${find_in_parent_folders("resource-group.yaml", local.global_yaml_path)}")
            )
}


terraform {
  before_hook "before_hook_plan" {
    commands     = ["plan"]
    execute      = ["bash", "${local.before_hook_script_path}", "${local.release_version_path}", "before-plan", local.skip_hooks_scripts]
    run_on_error = true
  }

  before_hook "before_hook_apply" {
    commands     = ["apply"]
    execute      = ["bash", "${local.before_hook_script_path}", "${local.release_version_path}", "before-apply", local.skip_hooks_scripts]
    run_on_error = false
  }

  after_hook "after_hook_plan" {
    commands     = ["plan"]
    execute      = ["bash", "${local.after_hook_script_path}", "${local.release_version_path}", "after-plan", local.skip_hooks_scripts]
    run_on_error = true
  }

  after_hook "after_hook_apply" {
    commands     = ["apply"]
    execute      = ["bash", "${local.after_hook_script_path}", "${local.release_version_path}", "after-apply", local.skip_hooks_scripts]
    run_on_error = false
  }
}


# Configure Terragrunt to automatically store tfstate files in Azure Blob Container
remote_state {
  backend = "azurerm"
  disable_dependency_optimization = true
  config = {
      key = "${path_relative_to_include()}/terraform.tfstate"
              resource_group_name = "ccp-qa-apim"
      storage_account_name = "ccpqaapim" #TBD
      container_name       = "live-terragrunt-state" #TBD
    }
}


# Configure variables that all resources can inherit. This is helpful with multi-tenant or multi-subscription configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge (
  local.global_vars,
  local.subscription_vars,
  local.env_vars,
  local.role_vars,
  local.version_vars,
  local.resource_group_vars
)

# generate "provider" {
#   path      = "provider.tf"
#   if_exists = "overwrite_terragrunt"
#   contents  = <<EOF
# terraform {
#   required_providers {
#     azurerm = {
#       source = "hashicorp/azurerm"
#       version = ">=2.99.0"
#     }
#   }
# }

# # Configure the Microsoft Azure Provider
# provider "azurerm" {
#   features {}
# }
# EOF
# }