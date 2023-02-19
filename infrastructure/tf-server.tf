resource "aws_launch_configuration" "configuration" {
  name             = "webapp"
  image_id         = coalesce(data.aws_ami.ubuntu.id, var.ami)
  instance_type    = "t2.micro"
  key_name         = aws_key_pair.key.key_name
  security_groups  = [aws_security_group.sg.id]
  user_data_base64 = data.cloudinit_config.web_app.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "autoscaling" {
  name                      = "shopping-app"
  vpc_zone_identifier       = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id]
  launch_configuration      = aws_launch_configuration.configuration.name
  min_size                  = 2
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  load_balancers            = [aws_elb.elb.name]
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "ec2 instance"
    propagate_at_launch = true
  }
}

resource "aws_elb" "elb" {
  name            = "elb"
  subnets         = [aws_subnet.main-public-1.id, aws_subnet.main-public-2.id]
  security_groups = [aws_security_group.elb-securitygroup.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = "arn:aws:acm:us-east-1:375866976303:certificate/c91ed6f3-6110-48c3-9292-b5a63ac89eeb"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  connection_draining         = true
  connection_draining_timeout = 400
  tags = {
    Name = "my-elb"
  }
}

resource "aws_key_pair" "key" {
  key_name   = "webkey"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDL0I/GAzvNcexFJRoVuDudqIcfUKfn7Asdat40C/1zcI7Y+98SmBSihjVeI//X3F2RGlOwVCsyBy1CeW9+aPIOHde41xoVYWV0dTFFpOQyUthOqE8peD904tyT7D2VP4xzyv5IBvl5zeOklx6BvdJBoxAXv63oWh4AVGE45k8gDsyz1Jln/7lG8jdoaDnNRqjUssnRkt1UC8KLQkzVQEnp0P7BJfxrFwUXnddi8u45M+37yCXiYRPV5lcN05smEiIW4lR0qFy5aivLxVnGjQ1k7G5sXXeLSmgapQQCxEHVRiVNK2ZRNmwaUpK+/KYkRg9W5yBtK/KVBfJeBjia4pUgn2W68N2OYXso4GKjuUzYcGAq8Hck/21hMxUWMdlxQdmOiQieb4zwqLEFG34rHZcFgWIys6sE3P5AfgZtMayqPl3qxKCUgg4/eiTlXYHIHnq42+BU/CGpbG6qNwzXjzMmfZj6iVMiJk/TITTwVakRfAJuMDAoYaFNQoNZhrCKeD8= lbena@LAPTOP-QB0DU4OG"
}

resource "aws_security_group" "sg" {
  name        = "server-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["76.198.149.152/32"]
  }

  ingress {
    description     = "TLS from VPC"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.elb-securitygroup.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssh"
  }
}

resource "aws_security_group" "elb-securitygroup" {
  vpc_id      = aws_vpc.main.id
  name        = "elb"
  description = "security group for load balancer"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["76.198.149.152/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["76.198.149.152/32"]
  }

  tags = {
    Name = "elb"
  }
}
