variable "region" {
  default = "us-east-2"
}

variable "cluster_name" {
  default = "EKS_CLUSTER"
}

variable "node_group_name" {
  default = "node-group"
}

variable "instance_type" {
  default = "t3.large"
}