variable "region" {
  type        = string
  description = "The is the Azure region the resources will be deployed into."
  validation {
    condition     = contains(["northeurope", "westeurope"], var.region)
    error_message = "The region is not in the correct region, it should be northeurope or westeurope."
  }
}

variable "environment" {
  type        = string
  description = "The is the environment the resources belong to. e.g. learning, development, production."
  validation {
    condition     = contains(["learning", "development", "production"], var.environment)
    error_message = "The environment is not valid, it should be learning, development or production."
  }
}

variable "team" {
  type        = string
  description = "The is the team that own the resources."
  validation {
    condition     = contains(["datagriff", "hungovercoders", "dogadopt", "platform"], var.team)
    error_message = "The team is not valid, it should be datagriff, hungovercoders or dogadopt."
  }
}

variable "organisation" {
  type        = string
  description = "The is the organisation that owns the resources."
  validation {
    condition     = contains(["datagriff", "hungovercoders", "dogadopt"], var.organisation)
    error_message = "The organisation is not valid, it should be datagriff, hungovercoders or dogadopt."
  }
}

variable "domain" {
  type        = string
  default     = "platform"
  description = "The is the business problem domain being solved by the resources."
}

variable "unique_namespace" {
  type        = string
  default     = "hngc"
  description = "The is the unique namespace added to resources."
}

variable "eventhubs" {
  description = "List of Event Hubs with their properties"
  type = list(object({
    domain_name = string
    events = list(object({
      name              = string
      partition_count   = number
      message_retention = number
      consumer_groups   = list(string)
    }))
  }))
  default = [
    {
      domain_name = "beer"
      events = [
        {
          name              = "beer.cdc.pub.v1",
          partition_count   = 4,
          message_retention = 4,
          consumer_groups   = ["beer.lake", "beer.pintreviews"]
        },
        {
          name              = "beer.fct.pintreview.v1",
          partition_count   = 4,
          message_retention = 4,
          consumer_groups   = ["beer.lake", "marketing.crm"]
        }
      ]
    }
  ]
}


locals {
  region_shortcode        = (var.region == "northeurope" ? "eun" : var.region == "westeurope" ? "euw" : "unk")
  environment_shortcode   = (var.environment == "learning" ? "lrn" : var.environment == "development" ? "dev" : var.environment == "production" ? "prd" : "unk")
  resource_group_name     = "${local.environment_shortcode}-events001-rg-${var.unique_namespace}"
  eventhub_namespace_name = "${local.environment_shortcode}-events001-ehns-${local.region_shortcode}-${var.unique_namespace}"

  tags = {
    environment  = var.environment
    organisation = var.organisation
    team         = var.team
    domain       = var.domain
  }

  unique_domains = { for eh in var.eventhubs : eh.domain_name => eh.domain_name }

  flattened_eventhubs = flatten([
    for domain in var.eventhubs : [
      for event in domain.events : {
        domain_name       = domain.domain_name
        name              = event.name
        partition_count   = event.partition_count
        message_retention = event.message_retention
        consumer_groups   = event.consumer_groups
        tags = {
          environment  = var.environment
          organisation = var.organisation
          team         = domain.domain_name
          domain       = domain.domain_name
        }
      }
    ]
  ])
}

locals {
  flattened_consumer_groups = flatten([
    for domain in var.eventhubs : [
      for event in domain.events : [
        for cg in event.consumer_groups : {
          domain_name    = domain.domain_name
          eventhub_name  = event.name
          consumer_group = cg
        }
      ]
    ]
  ])
}
