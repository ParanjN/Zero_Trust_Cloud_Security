# Vulnerable Workloads Configuration

# Linux EC2 Instance with Vulnerable WordPress
resource "aws_instance" "wordpress" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type_linux
  subnet_id     = var.private_subnet_ids[0]

  user_data = templatefile("${path.module}/scripts/install_wordpress.sh", {
    wordpress_version = "4.9.0" # Intentionally vulnerable version
  })

  vpc_security_group_ids = [aws_security_group.wordpress.id]
  iam_instance_profile   = aws_iam_instance_profile.vulnerable_profile.name

  root_block_device {
    volume_size = 30
    encrypted   = true
  }

  tags = merge(var.tags, {
    Name = "vulnerable-wordpress"
  })
}

# Windows EC2 Instance
resource "aws_instance" "windows" {
  ami           = data.aws_ami.windows.id
  instance_type = var.instance_type_windows
  subnet_id     = var.private_subnet_ids[1]

  vpc_security_group_ids = [aws_security_group.windows.id]
  iam_instance_profile   = aws_iam_instance_profile.vulnerable_profile.name

  root_block_device {
    volume_size = 100
    encrypted   = true
  }

  tags = merge(var.tags, {
    Name = "vulnerable-windows"
  })
}

# Vulnerable RDS Instance
resource "aws_db_instance" "vulnerable_db" {
  identifier           = "vulnerable-db"
  allocated_storage    = 20
  engine              = "mysql"
  engine_version      = "5.7"
  instance_class      = var.rds_instance_class
  name                = "vulndb"
  username            = "admin"
  password            = random_password.db_password.result
  skip_final_snapshot = true

  vpc_security_group_ids = [aws_security_group.db.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name

  backup_retention_period = 7
  multi_az               = false

  tags = merge(var.tags, {
    Name = "vulnerable-rds"
  })
}

# EKS Cluster with Vulnerable Configurations
resource "aws_eks_cluster" "vulnerable_cluster" {
  name     = "vulnerable-eks"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = merge(var.tags, {
    Name = "vulnerable-eks"
  })
}

# EKS Node Group
resource "aws_eks_node_group" "vulnerable_nodes" {
  cluster_name    = aws_eks_cluster.vulnerable_cluster.name
  node_group_name = "vulnerable-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = [var.eks_node_type]

  tags = merge(var.tags, {
    Name = "vulnerable-eks-nodes"
  })
}

# Vulnerable IAM Role (Overly Permissive)
resource "aws_iam_role" "vulnerable_role" {
  name = "vulnerable-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vulnerable_policy" {
  role       = aws_iam_role.vulnerable_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" # Intentionally overly permissive
}