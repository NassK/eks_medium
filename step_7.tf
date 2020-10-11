# Step 7: Deploying an app that can describe EC2 instances and push to Amazon s3
resource "random_string" "random" { # To help us get a random bucket name
  length = 10
  special = false
  upper = false
}

resource "aws_s3_bucket" "my_s3_pusher_pod_bucket" {
  bucket = "my-s3-test-bucket-${random_string.random.result}"
}

resource "aws_iam_role" "my_s3_pusher_pod_role" { # That role can be assumed by the service account thanks to the open id provider
  name = "my_s3_pusher_pod_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = "${aws_iam_openid_connect_provider.cluster.arn}"
      },
      Condition = {
        StringEquals = {
          "${replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")}:sub": "system:serviceaccount:${var.my_s3_pusher_serviceaccount_namespace}:${var.my_s3_pusher_serviceaccount_name}"
        }
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "my_s3_pusher_pod_policy" { # Allow to describe instance and to push on the created S3 bucket
  name        = "my_s3_pusher_pod_policy"
  path        = "/"

  policy = jsonencode({
    Statement = [{
      Action = [
          "ec2:DescribeInstances"
        ],
      Effect = "Allow",
      Resource = "*"
    },
    {
      Action = [
          "s3:PutObject"
        ],
      Effect = "Allow",
      Resource = "${aws_s3_bucket.my_s3_pusher_pod_bucket.arn}/*"
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "policy-DescribeInstancesAndPutObject" {
  policy_arn = aws_iam_policy.my_s3_pusher_pod_policy.arn
  role       = aws_iam_role.my_s3_pusher_pod_role.name
}

data "template_file" "app_yaml" { # This generate YAML creates the Pod and the service account

  template = file("${path.module}/app.yaml.tpl")

  vars = {
    app_iam_role_arn = aws_iam_role.my_s3_pusher_pod_role.arn
    s3_bucket = aws_s3_bucket.my_s3_pusher_pod_bucket.id
    service_account_name = var.my_s3_pusher_serviceaccount_name
  }
}

resource "null_resource" "deploy_app" {
  provisioner "local-exec" {
    command = "echo '${data.template_file.app_yaml.rendered}' > app.yaml && kubectl apply -f app.yaml"
  }
}