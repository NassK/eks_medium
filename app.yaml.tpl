apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${service_account_name}
  namespace: default
  annotations:
    eks.amazonaws.com/role-arn: ${app_iam_role_arn}
---
apiVersion: v1
kind: Pod
metadata:
  name: mys3pusher-pod
spec:
  serviceAccountName: ${service_account_name}
  containers:
    - name: mys3pusher-container
      image: amazon/aws-cli
      command: ["/bin/sh", "-c", "aws ec2 describe-instances > results.json && aws s3api put-object --bucket=${s3_bucket} --key=results.json --body=./results.json"]
