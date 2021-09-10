variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "eu-central-1"
}

variable "twitter_api_key" {
  description = "Twitter API Key"
  type        = string
  sensitive   = true
}

variable "twitter_api_secret" {
  description = "Twitter API Key SECRET"
  type        = string
  sensitive   = true
}

variable "twitter_access_token" {
  description = "Twitter Access Token"
  type        = string
  sensitive   = true
}

variable "twitter_access_token_secret" {
  description = "Twitter Access Token SECRET"
  type        = string
  sensitive   = true
}

variable "twitter_user" {
  description = "The screen name of user service is querying"
  type        = string
  sensitive   = false
}
variable "cache_results_seconds" {
  description = "How many seconds to cache the Twitter API results"
  type        = number
  sensitive   = false
}