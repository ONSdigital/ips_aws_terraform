data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      # prod/dev user
      identifiers = ["${aws_iam_user.concourse_user.arn}"]
      type        = "AWS"
    }
  }
}

resource "aws_iam_role" "concourse_role" {
  name               = "ips-concourse-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "ec2_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.concourse_role.name
}

resource "aws_iam_role_policy_attachment" "s3_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.concourse_role.name
}

resource "aws_iam_role_policy_attachment" "dynamoDB_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = aws_iam_role.concourse_role.name
}

resource "aws_iam_role_policy_attachment" "RDS_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  role       = aws_iam_role.concourse_role.name
}

resource "aws_iam_role_policy_attachment" "ECS_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
  role       = aws_iam_role.concourse_role.name
}

resource "aws_iam_role_policy_attachment" "ECR_private_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess"
  role       = aws_iam_role.concourse_role.name
}
resource "aws_iam_role_policy_attachment" "ECR_full_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = aws_iam_role.concourse_role.name
}

resource "aws_iam_role_policy" "concourse_policy" {
  name = "ips-concourse-policy"
  role = aws_iam_role.concourse_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "logs:ListTagsLogGroup",
          "ec2:DescribeInstances",
          "logs:DescribeLogStreams",
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "iam:ListInstanceProfilesForRole",
          "iam:DetachRolePolicy",
          "iam:ListEntitiesForPolicy",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeImages",
          "iam:DeleteRolePolicy",
          "iam:GetRole",
          "iam:PassRole",
          "logs:DescribeLogGroups",
          "logs:DeleteLogGroup",
          "s3:*",
          "ec2:DeleteNetworkInterface",
          "iam:DeleteRole",
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
          "ec2:CreateNetworkInterface",
          "ec2:AttachNetworkInterface",
          "route53:ListHostedZones",
          "route53:GetHostedZone",
          "route53:ListTagsForResource",
          "ecs:CreateCluster",
          "ecs:RegisterTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "route53:ChangeResourceRecordSets",
          "ecs:DescribeClusters",
          "ecs:DescribeTaskDefinition",
          "route53:GetChange",
          "route53:ListResourceRecordSets",
          "ecs:DeregisterTaskDefinition",
          "ecs:DeleteCluster",
          "ecs:CreateService",
          "ecs:DescribeServices",
          "acm:RequestCertificate",
          "acm:DescribeCertificate",
          "acm:ListTagsForCertificate",
          "acm:DeleteCertificate",
          "ec2-instance-connect:SendSSHPublicKey"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}
