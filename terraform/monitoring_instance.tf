resource "aws_instance" "monitoring" {
  ami                    = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.monitoring.id]
  key_name               = var.key_name

  iam_instance_profile = aws_iam_instance_profile.monitoring.name

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name    = "${var.project_name}-Server"
    Role    = "monitoring"
    Project = "CloudMonitoring"
  }

  user_data = templatefile(
    "${path.module}/monitoring_userdata.sh",
    {
      repository_url = var.repository_url
    }
  )
}