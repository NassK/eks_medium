# Step 5: Allowing Service Accounts to assume IAM roles
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

resource "aws_iam_openid_connect_provider" "cluster" { # We need an open id connect provider to allow our service account to assume an IAM role
  client_id_list = ["sts.amazonaws.com"]
thumbprint_list = concat([data.tls_certificate.cluster.certificates.0.sha1_fingerprint], [])
  url = aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}
