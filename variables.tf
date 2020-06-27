variable "region" {
  type        = string
  description = "AWS regional endpoint."
}

variable "hostname" {
  type        = string
  description = "Linux hostname."
}

variable "username" {
  type        = string
  description = "Linux username."
}

variable "instance_size" {
  type        = string
  description = "EC2 instance size."
}

variable "storage_size" {
  type        = number
  description = "Immutable EBS storage size for /home."
}

variable "route53_zone_id" {
  type        = string
  description = "Route53 hosted zone ID for DNS entries."
}

variable "domain_name" {
  type        = string
  description = "Domain name value to register in hosted zone. Eg. 'ide.mydomain.com'"
}

variable "github_username" {
  type        = string
  description = "GitHub username for importing SSH keys onto the instance."
}

variable "email_address" {
  type        = string
  description = "Email address for locking down OAuth to prevent it from being organization/account-wide."
  default     = ""
}

variable "oauth_provider" {
  type        = string
  description = "OAuth2 Proxy provider."
  default     = "google"
}

variable "oauth_client_id" {
  type        = string
  description = "OAuth client ID for chosen OAuth provider."
}

variable "oauth_client_secret" {
  type        = string
  description = "OAuth client secret for chosen OAuth provider."
}