# IAM Role and Policies for Monitoring Server
resource "aws_iam_role" "monitoring" {
  name = "CloudMonitoring-MonitoringRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ec2_discovery" {
  name = "EC2DiscoveryPolicy"
  role = aws_iam_role.monitoring.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DescribeRegions"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "monitoring_slack_secret" {
  name = "ReadSlackWebhookSecret"
  role = aws_iam_role.monitoring.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = var.webhook_secret_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "monitoring_ssm" {
  role       = aws_iam_role.monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "application" {
  name = "CloudMonitoring-ApplicationRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "application_ssm" {
  role       = aws_iam_role.application.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "monitoring" {
  name = "CloudMonitoring-MonitoringProfile"
  role = aws_iam_role.monitoring.name
}

resource "aws_iam_instance_profile" "application" {
  name = "CloudMonitoring-ApplicationProfile"
  role = aws_iam_role.application.name
}