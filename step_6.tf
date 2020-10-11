# Step 6: Adding the worker nodes + CNI + Kubernetes Cluster Autoscaler
resource "null_resource" "install_calico" { # The node won't enter the ready state without a CNI initialized
  provisioner "local-exec" {
    command = "kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml"
  }

  depends_on = [null_resource.generate_kubeconfig]
}

data "template_file" "aws_auth_configmap" { # Generates the aws-auth, otherwise, worker node can't join. Use this cm to add users/role to your cluster

  template = file("${path.module}/aws-auth-cm.yaml.tpl")

  vars = {
    arn_instance_role = aws_iam_role.node_group.arn
  }
}

resource "null_resource" "apply_aws_auth_configmap" { # Apply the aws-auth config map

  provisioner "local-exec" {
    command = "echo '${data.template_file.aws_auth_configmap.rendered}' > aws-auth-cm.yaml && kubectl apply -f aws-auth-cm.yaml && rm aws-auth-cm.yaml"
  }
  

  depends_on = [null_resource.generate_kubeconfig]
}

resource "aws_eks_node_group" "node_group" { # One node group per AZ (each AZ has its own private subnet)
  count = length(module.vpc.private_subnets)

  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "fnode_group-${substr(module.vpc.private_subnets[count.index], 7, length(module.vpc.private_subnets[count.index]))}"
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = [module.vpc.private_subnets[count.index]]

  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

  depends_on = [null_resource.apply_aws_auth_configmap]
}

resource "aws_iam_role" "node_group" {
  name = "eks_node_group_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "policy-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group.name
}

resource "aws_iam_role_policy_attachment" "policy-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group.name
}

data "template_file" "cluster_autoscaler_yaml" { # Generate the cluster autoscaler from a template
  template = file("${path.module}/cluster-autoscaler.yaml.tpl") 

  vars = {
    cluster_name = aws_eks_cluster.cluster.name
  }
}

resource "null_resource" "cluster_autoscaler_install" { # Install the cluster autoscaler
  provisioner "local-exec" {
    command = "echo '${data.template_file.cluster_autoscaler_yaml.rendered}' > cluster_autoscaler.yaml && kubectl apply -f cluster_autoscaler.yaml && rm cluster_autoscaler.yaml"
  }

  depends_on = [aws_eks_cluster.cluster, null_resource.generate_kubeconfig]
}

## From here, your cluster works. Below is an optional quick app to demonstrate running something with an IAM role.
