variable "env" {}

variable "aws" {
  type    = any
  default = {}
}

variable "dns" {
  type    = any
  default = {}
}

variable "custom_tags" {
  type    = any
  default = {}
}

variable "sftp" {
  type    = any
  default = {}
}

variable "sftp_users" {
  type    = any
  default = []
}
