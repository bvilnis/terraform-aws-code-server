variable "domain_name" {
  type        = string
  description = "A record value for supplied hosted zone (eg. 'mydomain.com' or 'subdomain.mydomain.com')"
}

variable "email_address" {
  type        = string
  description = "If set, OAuth2 Proxy will only authenticate supplied email address rather than entire org/account of the Oauth2 provider"
  default     = ""
}

variable "github_username" {
  type        = string
  description = "GitHub username for importing public SSH keys associated to the GitHub account"
}

variable "hostname" {
  type        = string
  description = "Hostname for the EC2 instance"
  default     = "code-server"
}

variable "instance_size" {
  type        = string
  description = "EC2 instance size"
  default     = "t3.small"
}

variable "oauth2_client_id" {
  type        = string
  description = "OAuth2 client ID key for chosen OAuth2 provider"
}

variable "oauth2_client_secret" {
  type        = string
  description = "OAuth2 client secret key for chosen OAuth2 provider"
}

variable "oauth2_provider" {
  type        = string
  description = "OAuth2 provider"
}

variable "region" {
  type        = string
  description = "AWS regional endpoint"
  default     = "us-east-1"
}

variable "azs" {
  type        = list(string)
  description = "A list of availability zones names or ids in the region. default is `[\"${var.region}a\", \"${var.region}b\", \"${var.region}c\"]`"
  default     = []
}

variable "route53_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for `domain_name`"
}

variable "storage_size" {
  type        = number
  description = "Size (in GB) for immutable EBS volume mounted to `/home`"
  default     = 20
}

variable "username" {
  type        = string
  description = "Username for the non-root user on the EC2 instance"
  default     = "coder"
}
