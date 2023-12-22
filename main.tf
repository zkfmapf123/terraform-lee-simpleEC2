##################################################################
## EC2
##################################################################
resource "aws_instance" "instance" {

  ############################### os options ###############################
  ami           = var.instance_ami
  instance_type = var.instance_type

  ############################### network options ###############################
  availability_zone           = var.instance_region
  associate_public_ip_address = lookup(var.instance_ip_attr, "is_public_ip")
  private_ip                  = lookup(var.instance_ip_attr, "is_private_ip") ? lookup(var.instance_ip_attr, "private_ip") : null
  subnet_id                   = var.instance_subnet_id
  vpc_security_group_ids      = var.instance_sg_ids


  ############################### hardware option ###############################
  ### device options
  root_block_device {
    volume_size = lookup(var.instance_root_device, "size")
    volume_type = lookup(var.instance_root_device, "type")
  }

  ### cpu option
  dynamic "cpu_options" {
    for_each = lookup(var.instance_cpu_option, "is_alloc_cpu_option") && !strcontains(var.instance_type, "micro") ? [1] : []

    content {
      core_count       = lookup(var.instance_cpu_option, "core_count")
      threads_per_core = lookup(var.instance_cpu_option, "threads_per_core")
    }
  }

  ############################### ETC option ###############################
  key_name = lookup(var.instance_key_attr, "is_alloc_key_pair") ? lookup(var.instance_key_attr, "key_name") : lookup(var.instance_key_attr, "is_use_key_path") ? aws_key_pair.ins_keypair[0].key_name : null

  ## IAM
  iam_instance_profile = var.instance_iam != "x" ? var.instance_iam : null

  ## USER_DATA
  user_data = var.user_data_file == "" ? null : file(var.user_data_file)

  ## Tag
  tags = merge({
    Name     = var.instance_name
    Resource = "ec2"
  }, var.instance_tags)

  ## LifeCycle 
  lifecycle {
    ignore_changes = [user_data]
  }

  ## Metadata Tag Options
  metadata_options {
    instance_metadata_tags = var.is_enable_metadata_tag ? "enabled" : "disabled"
  }
}

##################################################################
## EC2 EIP (선택)
##################################################################
resource "aws_eip" "ins_eip" {
  count = lookup(var.instance_ip_attr, "is_eip") ? 1 : 0

  vpc      = true
  instance = aws_instance.instance.id

  tags = {
    Name     = "${var.instance_name}-eip"
    Resource = "eip"
  }
}

resource "aws_eip_association" "eip_assoc" {
  count = lookup(var.instance_ip_attr, "is_eip") ? 1 : 0

  instance_id   = aws_instance.instance.id
  allocation_id = aws_eip.ins_eip[0].id
}

##################################################################
## AWS EC2 Keypair
##################################################################
resource "aws_key_pair" "ins_keypair" {
  count = lookup(var.instance_key_attr, "is_use_key_path") ? 1 : 0

  key_name   = lookup(var.instance_key_attr, "key_name")
  public_key = file(lookup(var.instance_key_attr, "key_path"))

  tags = {
    Name     = "${lookup(var.instance_key_attr, "key_name")}-keypair"
    Resource = "keypair"
  }
}
