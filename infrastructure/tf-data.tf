data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "cloudinit_config" "web_app" {
  gzip          = true
  base64_encode = true
  part {
    content_type = "text/x-shellscript"
    filename     = "web_app"
    content = templatefile("templates/webapp.tpl",
      {
        Repository  = var.Repository
        db_password = var.db_password
        connection  = var.connection
        username    = var.username
    })
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "db"
    content = templatefile("../app/src/com/shashi/utility/database.properties",
      {
        db_password = var.db_password
        username    = var.username
    })
  }
}

data "aws_route53_zone" "zone" {
  name         = "dev.elitesolutionsit.com"
  private_zone = false
}

