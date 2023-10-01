##################################################################
## Common
##################################################################
variable "instance_name" {
  type = string
}

##################################################################
## Network 
##################################################################
variable "instance_region" {
  type        = string
  description = "region"
}

variable "instance_subnet_id" {
  type        = string
  description = "subnet id"
}

variable "instance_sg_ids" {
  type        = list(string)
  description = "security group ids"
}

##################################################################
## EC2 Property
##################################################################
variable "instance_ami" {
  type        = string
  description = "ec2 ami"

  default = "ami-043a1babe609d076d"
}

variable "instance_type" {
  type        = string
  description = "ec2 instance_type"

  default = "t4g.small"
}

variable "instance_ip_attr" {
  type = object({
    is_public_ip  = bool   ## public_ip 옵션
    is_eip        = bool   ## eip를 등록할건지?
    is_private_ip = bool   ## private_ip를 사용할건지
    private_ip    = string ## private 직접 대응
  })

  validation {
    condition     = var.instance_ip_attr.is_public_ip != var.instance_ip_attr.is_private_ip
    error_message = "ip assoc must be public or private"
  }
}

##################################################################
## Hard Option
##################################################################
variable "instance_cpu_option" {
  description = "cpu option 입니다"
  type = object({
    is_alloc_cpu_option = bool
    core_count          = number
    threads_per_core    = number
  })

  default = {
    is_alloc_cpu_option = true
    core_count          = 2
    threads_per_core    = 1
  }
}

##################################################################
## Device Block
##################################################################
variable "instance_root_device" {
  description = "root device 옵션입니다."
  type = object({
    size = string
    type = string
  })

  default = {
    size = 20
    type = "gp3"
  }
}

##################################################################
## Key Name
##################################################################
variable "instance_key_attr" {
  description = "key attribute"

  type = object({
    is_alloc_key_pair = bool ## aws_key_pair 할당 여부
    is_use_key_path   = bool ## key_pair file 여부
    key_name          = string
    key_path          = string
  })

  validation {
    condition     = !(var.instance_key_attr.is_use_key_path == true && var.instance_key_attr.is_alloc_key_pair == true)
    error_message = "is_alloc_key_pair, is_use_key_path not allowed all true"
  }
}
