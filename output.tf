output "out" {
  value = {
    ec2_id = aws_instance.instance.id
  }
}
