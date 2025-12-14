variable "project_id" {
  type        = string
  description = "GCP Project ID"
  default     = "practice-portfolio-481213"
}

variable "region" {
  type        = string
  description = "GCP region"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "GCP zone"
  default     = "us-central1-a"
}

variable "ssh_username" {
  type        = string
  description = "Linux username for SSH login"
  default     = "ubuntu"
}

variable "ssh_public_key_path" {
  type        = string
  description = "Path to your SSH public key"
  default     = "~/.ssh/gcp_terraform_key.pub"
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to SSH (lock this down!)"
  default     = ["106.185.152.18/32","60.71.16.38/32"]
}
