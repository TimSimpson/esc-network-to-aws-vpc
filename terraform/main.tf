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
  cidr_block                       = "172.250.0.0/24"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false

  tags = {
    Name = local.project_name
  }

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
  tags = {
    Name = local.project_name
  }
}

// Set up the routes on the AWS side to be able to communicate with ESC
resource "aws_route" "aws_to_esc" {
  route_table_id            = aws_vpc.vpc.default_route_table_id
  destination_cidr_block    = eventstorecloud_network.network.cidr_block
  vpc_peering_connection_id = eventstorecloud_peering.peering.provider_metadata.aws_peering_link_id
}

resource "aws_subnet" "application" {
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 3, 1)
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "${var.region}a"
}

// allow everything. Dangerous, but you can't put a price on convenience
resource "aws_security_group" "application" {
  name   = local.project_name
  vpc_id = aws_vpc.vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}

data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["amazon"]
  // Event Store Cloud Platform

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "application" {
  ami             = data.aws_ami.ubuntu_latest.id
  instance_type   = "t2.micro"
  key_name        = var.key_pair
  security_groups = [aws_security_group.application.id]
  tags = {
    Name = local.project_name
  }
  subnet_id = aws_subnet.application.id
}

resource "aws_eip" "application" {
  instance = aws_instance.application.id
  vpc      = true
}

resource "aws_internet_gateway" "application" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = local.project_name
  }
}

resource "aws_route_table" "application" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.application.id
  }
  route {
    cidr_block                = eventstorecloud_network.network.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer.id
  }
  tags = {
    Name = local.project_name
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.application.id
  route_table_id = aws_route_table.application.id
}

resource "eventstorecloud_managed_cluster" "cluster" {
  name = local.project_name

  project_id = eventstorecloud_project.project.id
  network_id = eventstorecloud_network.network.id

  topology        = "single-node"
  instance_type   = "F1"
  disk_size       = 11
  disk_type       = "gp3"
  disk_iops       = 3000
  disk_throughput = 125
  server_version  = "22.10"
}
