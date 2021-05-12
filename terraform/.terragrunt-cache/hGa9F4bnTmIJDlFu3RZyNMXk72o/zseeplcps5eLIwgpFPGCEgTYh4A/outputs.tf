output "concourse_user_id" {
  value = aws_iam_access_key.concourse_user.id
}

output "concourse_user_secret" {
  value = aws_iam_access_key.concourse_user.secret
}

output "concourse_role_arn" {
  value = aws_iam_role.concourse_role.arn
}

output "concourse_secret_config" {
  value = <<-EOF
access_key_id=${aws_iam_access_key.concourse_user.id}
secret_access_key=${aws_iam_access_key.concourse_user.secret}
deploy_role=${aws_iam_role.concourse_role.arn}
EOF
}
