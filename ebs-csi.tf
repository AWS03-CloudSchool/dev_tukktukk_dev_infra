# ebs-csi-driver용 IAM Role 생성
resource "aws_iam_role" "ebs_csi_iam_role" {
  depends_on = [aws_iam_policy.ca_iam_policy]
  name = "aws-ebs-csi-irsa-role-${var.infra_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.oidc_provider.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${local.oidc_provider}:aud" = "sts.amazonaws.com",
            "${local.oidc_provider}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_iam_role_attach" {
    role = aws_iam_role.ebs_csi_iam_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    depends_on = [ aws_iam_role.ebs_csi_iam_role ]
}

resource "helm_release" "aws_ebs_csi_driver" {
  name          = "aws-ebs-csi-driver"
  repository    = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart         = "aws-ebs-csi-driver"
  namespace     = "kube-system"

  set{
    name    = "controller.serviceAccount.create"
    value   = "true"
  }

  set {
    name    = "controller.serviceAccount.name"
    value   = "ebs-csi-controller-sa"
  }

  set {
    name    = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value   = aws_iam_role.ebs_csi_iam_role.arn
  }
}