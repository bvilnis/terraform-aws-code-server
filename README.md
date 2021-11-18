# AWS Code Server Terraform module

Terraform module which creates an OAuth2-authenticated [Code Server](https://github.com/cdr/code-server) on AWS.

## Usage

```hcl
//--------------------------------------------------------------------
// Variables
variable "oauth2_client_id" {}
variable "oauth2_client_secret" {}

//--------------------------------------------------------------------
// Modules
module "code-server" {
  source  = "bvilnis/code-server/aws"
  version = "0.1.1"

  domain_name          = "ide.mydomain.com"
  email_address        = "email@mydomain.com"
  github_username      = "bvilnis"
  hostname             = "code-server"
  instance_size        = "t3.small"
  oauth2_client_id     = var.oauth2_client_id
  oauth2_client_secret = var.oauth2_client_secret
  oauth2_provider      = "google"
  region               = "us-east-1"
  route53_zone_id      = "Z23ABC4XYZL05B"
  storage_size         = 20
  username             = "coder"
}
```

```
terraform apply \
-var="oauth2_client_id=<client_id>" \
-var="oauth2_client_secret=<client_secret>"
```

## Notes

* The `oauth_client_id` and `oauth_client_secret` variables should not be defined in code as they are considered sensitive values. When used with with CLI, set them as [variables on the command line](https://www.terraform.io/docs/configuration/variables.html#variables-on-the-command-line), as outlined above. When used in [Terraform Cloud](https://www.terraform.io/), set them as [sensitive variables](https://www.terraform.io/docs/cloud/workspaces/variables.html#sensitive-values).
* The sudo password for your created user can be found at `/home/$USER/sudo.txt`. It is recommended you run `passwd` to change your password and then delete this file.
* User data on EC2 can take several minutes to execute and complete. Allow enough time for the instance to launch and execute the commands in [user_data.tpl](user_data.tpl).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

* [OAuth2 client ID and secret](https://oauth2-proxy.github.io/oauth2-proxy/auth-configuration) from your chosen provider.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| domain_name | An A record value for hosted zone (eg. 'mydomain.com' or 'subdomain.mydomain.com') | `string` | n/a | yes |
| email_address | If set, OAuth2 Proxy will only authenticate supplied email address rather than entire org/account of the OAuth2 provider | `string` | `""` | no |
| github_username | GitHub username for importing public SSH keys associated to the GitHub account | `string` | n/a | yes |
| hostname | Hostname for the EC2 instance | `string` | `"code-server"` | no |
| instance_size | EC2 instance size | `string` | `"t3.small"` | no |
| oauth2_client_id | OAuth2 client ID key for chosen OAuth2 provider | `string` | n/a | yes |
| oauth2_client_secret | OAuth2 client secret key for chosen OAuth2 provider | `string` | n/a | yes |
| oauth2_provider | OAuth2 provider | `string` | n/a | yes |
| region | AWS regional endpoint | `string` | `"us-east-1"` | no |
| azs | A list of availability zones names or ids in the region | `list(string)` | `["${var.region}a", "${var.region}b", "${var.region}c"]` | no |
| route53_zone_id | Route53 hosted zone ID for `domain_name` | `string` | n/a | yes |
| storage_size | Size (in GB) for immutable EBS volume mounted to `/home` | `number` | `20` | no |
| username | Username for the non-root user on the EC2 instance | `string` | `"coder"` | no |

## Outputs

| Name | Description |
|------|-------------|
| domain_name | The domain name record |
| ec2_id | EC2 instance ID |
| ec2_private_ip | EC2 instance private IP address |
| ec2_public_ip | EC2 instance public IP address |
| public_subnets | List of IDs of public subnets |
| public_subnet_cidr_blocks | List of cidr_blocks of public subnets |
| security_group_id | The ID of the security group |
| vpc_id | The ID of the VPC |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Authors

Module managed by [Ben Vilnis](https://github.com/bvilnis).

## License

Apache 2 Licensed. See LICENSE for full details.
