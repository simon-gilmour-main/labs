variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "allowed_cidr" {
  type        = string
  description = "Your public IP in CIDR form, e.g. 1.2.3.4/32"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "Optional EC2 key pair name for SSH"
  default     = null
}
 
variable "root_volume_size" {
  description = "Size of the root EBS volume in GB"
  type        = number
  default     = 20
}
