terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.43.0"
    }

    random = {
      source = "hashicorp/random"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {
    
  }
}