output "public_ip" {
  value = aws_instance.lab.public_ip
}

output "public_dns" {
  value = aws_instance.lab.public_dns
}

output "ssh_user" {
  value = "ares"
}

output "instance_id" {
  value = aws_instance.lab.id
}
