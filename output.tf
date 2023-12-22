output "out" {
  value = {
    ec2_id    = aws_instance.instance.id
    public_ip = lookup(var.instance_ip_attr, "is_eip") ? aws_instance.instance.public_ip : ""
  }
}
