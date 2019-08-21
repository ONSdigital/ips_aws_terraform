This repository creates a VPC for IPS' ECS Cluster on AWS


When invoking `tf apply` the following params needs to be passed in:

```
variable "bastion_ingress_ip" {}
variable "deploy_key_name" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "common_name" {}
```

The above vars can either be passed in using `-var` directly on the command line or a `.tfvars` file can be setup like so:
```
❯ cat $HOME/.aws/terraform-ons.tfvars                                                                                                                                                                    <ons.ash.jindal> [12-Aug 12:44:46]
aws_access_key = "redacted"
aws_secret_key = "redacted"
```


For instance, the following command uses a combination of both the approaches, by specifying vars that may change on the command line directly and moving the
vars that contains sensitive information to the .tfvars file so that they do not end up in the shell history:
```
tf plan \
    -var "bastion_ingress_ip=$(curl --silent  ifconfig.co)" \
    -var "deploy_key_name=ConcDeploy"  \
    -var "common_name=ips-vpc-test2"   \
    -var-file=$HOME/.aws/tf-creds.tfvars 
```