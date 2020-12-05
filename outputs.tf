output "jumphost_public_ip"{
    value = aws_instance.Jumphost.public_ip
}

output "apache1_private_ip"{
    value = aws_instance.apache1.public_ip
}

output "apache2_public_ip"{
    value = aws_instance.apache2.public_ip
}

output "alb_address" {
    value = aws_alb.alb.dns_name
}