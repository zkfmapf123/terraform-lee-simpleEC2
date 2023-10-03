provider "aws" {
  profile = "leedonggyu"
}

resource "aws_security_group" "ins-sg" {
  vpc_id      = "vpc-06151804b151e2c54"
  name        = "inst-sg"
  description = "description"

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
    Name = "default-ins-sg"
  }
}

module "default-private-ins" {
  source = "../../"

  instance_name      = "private_ins"
  instance_region    = "ap-northeast-2a"
  instance_subnet_id = "subnet-0082ef1bd2a8cb458"
  instance_sg_ids    = [aws_security_group.ins-sg.id]

  #   instance_ami = ""
  #   instance_type = ""

  instance_ip_attr = {
    is_public_ip  = false
    is_eip        = false
    is_private_ip = true
    private_ip    = ""
  }

  #   instance_cpu_option = {
  #     is_alloc_cpu_opiton = true
  #     core_count = 2
  #     threads_per_core = 2
  #   }

  # instance_root_device = {
  #     size =20
  #     type = "gp3"
  # }

  instance_key_attr = {
    is_alloc_key_pair = true
    is_use_key_path   = false
    key_name          = "example-key-pair"
    key_path          = ""
  }
}
