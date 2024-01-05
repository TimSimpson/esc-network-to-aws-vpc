output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "aws_vpc_arn" {
  value = aws_vpc.vpc.arn
}

output "public_ip" {
  value = aws_eip.application.public_ip
}

output "private_ip" {
  value = aws_eip.application.public_ip
}

output "cluster_dns_name" {
  value = eventstorecloud_managed_cluster.cluster.dns_name
}
