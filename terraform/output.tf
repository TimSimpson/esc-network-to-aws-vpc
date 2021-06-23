output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "lambda_name" {
  value = aws_lambda_function.lambda.function_name
}

output "aws_vpc_arn" {
  value = aws_vpc.vpc.arn
}