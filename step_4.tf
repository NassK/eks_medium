# Step 4: Configuring the Kubectl CLI
/**
 * NEEDS KUBECTL AND AWS CLI INSTALLED.
 */

resource "null_resource" "generate_kubeconfig" { # Generate a kubeconfig (needs aws cli >=1.62 and kubectl)

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}"
  }

  depends_on = [aws_eks_cluster.cluster]
}
