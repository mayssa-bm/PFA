variable "image_id" {
  type        = string
  default     = "98c4700c-537e-400d-a0a8-e55485b1d8fb"
  description = "The id of the machine image (AMI) to use for the server."
}

variable "ext_addr" {
  type        = string
  default     = "192.168.1.23/24"
  description = "The id of the external network"
}

variable "auth_url" {
  type        = string
  description = "The auth url of the openstack project "
}

variable "passwd" {
  type        = string
  description = "The password of the project"
}

variable "count_web" {
  type        = number
  default     = 2
  description = "number of web instances "
}

variable "count_data" {
  type        = number
  default     = 2
  description = "number of data instances "
}
