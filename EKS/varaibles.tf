variable "region" {
  description = "region in aws"
  type        = string
}

variable "cidr" {
  description = "cidr block for vpc"
  type        = string

}

variable "public_subnets" {
  description = "public subnet cidr "
  type        = list(string)
}

variable "private_subnets" {
  description = "public subnet cidr "
  type        = list(string)
}