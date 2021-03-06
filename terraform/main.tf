terraform {
  required_providers {
    eventstorecloud = {
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  project_name = "esdb_vpc_example_${var.stage}"
}

data "aws_caller_identity" "current" {}

resource "aws_vpc" "vpc" {
  cidr_block                       = "192.168.0.0/24"
  enable_dns_support               = false
  enable_dns_hostnames             = false
  assign_generated_ipv6_cidr_block = false
  enable_classiclink               = false
  enable_classiclink_dns_support   = false
}

resource "eventstorecloud_project" "project" {
  name = local.project_name
}

resource "eventstorecloud_network" "network" {
  name = local.project_name

  project_id = eventstorecloud_project.project.id

  resource_provider = "aws"
  region            = var.region
  cidr_block        = "172.21.0.0/16"
}

// Initiates a peering request from the Event Store Cloud Network and sets
// all necessary internal routes
resource "eventstorecloud_peering" "peering" {
  name = local.project_name

  project_id = eventstorecloud_network.network.project_id
  network_id = eventstorecloud_network.network.id

  peer_resource_provider = eventstorecloud_network.network.resource_provider
  peer_network_region    = eventstorecloud_network.network.region

  peer_account_id = data.aws_caller_identity.current.account_id
  peer_network_id = aws_vpc.vpc.id
  routes          = [aws_vpc.vpc.cidr_block]
}

// Accepts the initiated peering from the Event Store Cloud from our AWS account
resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws
  vpc_peering_connection_id = eventstorecloud_peering.peering.provider_metadata.aws_peering_link_id
  auto_accept               = true
}

// Set up the routes on the AWS side to be able to communicate with ESC
resource "aws_route" "aws_to_esc" {
  route_table_id            = aws_vpc.vpc.default_route_table_id
  destination_cidr_block    = eventstorecloud_network.network.cidr_block
  vpc_peering_connection_id = eventstorecloud_peering.peering.provider_metadata.aws_peering_link_id
}
