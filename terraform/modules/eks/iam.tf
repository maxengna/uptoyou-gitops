################################################################################
# EKS CLUSTER ROLE
################################################################################
resource "aws_iam_role" "EKSClusterRole" {
  name = "${var.naming_prefix}-EKSClusterRole"
  assume_role_policy = jsoncode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(var.common_tags, {
    Name = "EKSClusterRole"
  })
}

################################################################################
# EKS CLUSTER ROLE POLICY ATTACHMENT
################################################################################
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  role       = aws_iam_role.EKSClusterRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}




################################################################################
# NODE GROUP ROLE
################################################################################
resource "aws_iam_role" "NodeGroupRole" {
  name = "${var.naming_prefix}-EKSNodeGroupRole"
  assume_role_policy = jsoncode({
    Version = "2012-10-17"
    Statement = [{
      Action : "sts:AssumeRole"

    }]
  })

  tags = merge(var.common_tags, {
    Name = "NodeGroupRole"
  })
}

################################################################################
# NODE GROUP ROLE POLICY ATTACHMENT
################################################################################
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.NodeGroupRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.NodeGroupRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.NodeGroupRole.name
}
