terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "resource" {
  name     = "appservice_docker"
  location = "westus"
}

resource "azurerm_app_service_plan" "svcplan" {
  name                = "example-appserviceplan"
  location            = azurerm_resource_group.resource.location
  resource_group_name = azurerm_resource_group.resource.name
  kind = "Linux"
  reserved = true
  

  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "myapp" {
  name                = "docsify-learn"
  location            = azurerm_resource_group.resource.location
  resource_group_name = azurerm_resource_group.resource.name
  app_service_plan_id = azurerm_app_service_plan.svcplan.id
  https_only          = true
  
  site_config {
    http2_enabled = true
    linux_fx_version = "COMPOSE|${filebase64("compose.yml")}"
    # registry_source="Docker Hub"
    use_32_bit_worker_process = true
  }
    
}

output "URL" {
  value = azurerm_app_service.myapp.default_site_hostname
}
