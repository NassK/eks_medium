variable "region" {
    description = "The AWS region"
    default = "eu-west-1"
}

variable "my_s3_pusher_serviceaccount_namespace" {
  description = "The Kubernetes namespace the service account for my_s3_pusher pod will be created."
  default = "default"
}

variable "my_s3_pusher_serviceaccount_name" {
  description = "The Kubernetes service account name for MyS3Pusher app."
  default = "mys3pusher-serviceaccount"
}

variable "cluster_name" {
  description = "The name of the Amazon EKS cluster."
  default = "my-eks-cluster"
}
