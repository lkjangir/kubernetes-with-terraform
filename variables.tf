variable "subnet_id_1" {
  type = "string"
  default = "subnet-xxxxxxx"
}

variable "subnet_id_2" {
  type = "string"
  default = "subnet-xxxxxxxx"
}

variable "vpc_id" {
  type = "string"
  default = "vpc-xxxxxxxx"
}

variable "region" {
  type = "string"
  default = "us-west-1"
}

variable "cluster_name" {
  type = "string"
  default = "five.example.store"
}

variable "key_pair" {
  type = "string"
  default = "openkey"
}

variable "ami_id" {
  type = "string"
  default = "ami-zzzzzzzzzzzzzzzzz"
}

variable "master_instance_size" {
  type = "string"
  default = "t2.medium"
}

variable "node_instance_size" {
  type = "string"
  default = "t2.small"
}

variable "s3_bucket" {
  type = "string"
  default = "xyz-kops-state-test"
}

variable "r53_zone_id" {
  type = "string"
  default = "Z3OZL4CGERTJEWLTJE"
}

