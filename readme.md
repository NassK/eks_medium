# Kubernetes cluster on Amazon EKS with Terraform

![Amazon EKS logo](https://cdn-images-1.medium.com/max/1600/1*p-xHUUw1S37uLLpF8gUfmA.png)


This demo repo create an autoscaled EKS cluster with Terraform. Applying this repo takes approx 15-20 minutes.
[This repo is the result of this Medium post](https://medium.com/@nassim.kebbani/kickstart-your-kubernetes-cluster-on-amazon-eks-with-terraform-like-a-boss-in-7-steps-b7173c6a7526)

## Prerequisites

- An AWS account
- Terraform >=0.12
- AWS CLI >=1.62
- Kubectl

## How to run
```
git clone git@github.com:NassK/eks_medium.git && cd eks_medium


export AWS_ACCESS_KEY_ID=AKAIXXXXXX
export AWS_SECRET_ACCESS_KEY=XXXXXX

terraform init
terraform apply

```

## Destroying

Once you're done you should destroy everything to not spend much on AWS.

```
terraform destroy
```

Note: Keep in mind to empty the S3 bucket before destroying it.
