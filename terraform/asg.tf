resource "aws_launch_template" "application" {
  name_prefix   = "${var.project_name}-Application-"
  image_id      = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.application.id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.application.name
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name    = "${var.project_name}-Application"
      Role    = "application"
      Project = "CloudMonitoring"
    }
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e

    apt-get update
    apt-get install -y docker.io

    systemctl enable docker
    systemctl start docker

    usermod -aG docker ubuntu
  EOF
  )
}

resource "aws_autoscaling_group" "application" {
  name = "${var.project_name}-Application-ASG"

  min_size         = 2
  desired_capacity = 2
  max_size         = 4

  vpc_zone_identifier = aws_subnet.public[*].id

  target_group_arns = [
    aws_lb_target_group.application.arn
  ]

  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.application.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-Application"
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value               = "application"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "CloudMonitoring"
    propagate_at_launch = true
  }
}