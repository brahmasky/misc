# non standard hashicorp providers must be defined in child module
terraform {
  required_providers {
    artifactory = {
      source  = "jfrog/artifactory"
      version = "2.20.0"
    }
  }
}

# artifactory url ($ARTIFACTORY_URL) and api key ($ARTIFACTORY_API_KEY) to be provided by env variables
provider "artifactory" {
  check_license = false
}