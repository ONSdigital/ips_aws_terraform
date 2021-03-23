resource "aws_iam_user" "concourse_user" {
  name = "ips-concourse"
}

resource "aws_iam_access_key" "concourse_user" {
  user = aws_iam_user.concourse_user.name
}

resource "aws_iam_user_policy" "concourse_user" {
  name = "ips-concourse-user-policy"
  user = aws_iam_user.concourse_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "${aws_iam_role.concourse_role.arn}"
    }
  ]
}
EOF
}
