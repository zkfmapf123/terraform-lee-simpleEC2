provider "aws" {
  profile = "leedonggyu"
}

resource "aws_security_group" "userdata-temp-sg" {
  vpc_id      = "vpc-06151804b151e2c54"
  name        = "userdata-temp-sg"
  description = "description"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "userdata-temp-sg"
  }
}

## Freetier는 cpu 옵션을 사용할수 없습니다.
module "default-public-ins" {
  source = "../../"

  instance_name      = "freetier-ins"
  instance_region    = "ap-northeast-2a"
  instance_subnet_id = "subnet-0082ef1bd2a8cb458"
  instance_sg_ids    = [aws_security_group.userdata-temp-sg.id]

  instance_ami  = "ami-086cae3329a3f7d75" ## Linux amazon 2
  instance_type = "t2.micro"              ## t2.micro

  instance_ip_attr = {
    is_public_ip  = true
    is_eip        = true
    is_private_ip = false
    private_ip    = ""
  }

  # instance_root_device = {
  #     size =20
  #     type = "gp3"
  # }

  instance_key_attr = {
    is_alloc_key_pair = false
    is_use_key_path   = true
    key_name          = ""
    key_path          = "~/.ssh/id_rsa.pub"
  }

  instance_tags = {
    "Monitoring" : true,
    "MadeBy" : "terraform"
  }

  user_data_file         = "./user_data.sh"
  is_enable_metadata_tag = true
}

output "v" {
  value = module.default-public-ins
}
