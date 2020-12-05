
#ssh key-pair
resource "aws_key_pair" "ssh_key" {
    key_name = "instance_key1"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCoQjEDQZiJXS+Jasovuy7hkT+zpyoHUShox2SvUk5fWs8raJAr0t2Wjq2N9ksO93B+OXKPnpLh50hClXHE5g6l31zwgLsklY5CRLsbBaBrDjSbOCDr79FapWSxzJ4axsyAN3S7X1R5jT+MAE/dWuT+piQSnKdRsS/zHRWkA/jBh7dt0S/DSlrB+yd/Ry6QbrX7lWb1dm9O5HJgqUjaAca2VFwA6thEdzf3WLhHYn5u63K3ua7IjBe+MDcMNXmMCEQIlHdz12pqaTj0xtVzqoO2mh62DiaO1XqmKl6HnNju45jMWzv49QCnU38ZCktvvW2nx0nzskQblKURVFK49nY3"
}

#web servers
resource "aws_instance" "apache1" {
    instance_type          = "t2.micro"
    ami                    = "ami-0885b1f6bd170450c"
    subnet_id              = aws_subnet.private_subnet_1.id
    vpc_security_group_ids = [ aws_security_group.apache_sg.id ]
    key_name               = aws_key_pair.ssh_key.key_name
    user_data              = file("install_apache.sh")
    tags = {
        Name = "Apache1"
    }
}

resource "aws_instance" "apache2" {
    instance_type          = "t2.micro"
    ami                    = "ami-0885b1f6bd170450c"
    subnet_id              = aws_subnet.private_subnet_2.id
    vpc_security_group_ids = [ aws_security_group.apache_sg.id ]
    key_name               = aws_key_pair.ssh_key.key_name
    user_data              = file("install_apache.sh")
    tags = {
        Name = "Apache2"
    }
}

#jumphost server
resource "aws_instance" "Jumphost" {
    instance_type               = "t2.micro"
    ami                         = "ami-0885b1f6bd170450c"
    subnet_id                   = aws_subnet.public_subnet.id
    associate_public_ip_address = true
    vpc_security_group_ids      = [ aws_security_group.jumphost_sg.id ]
    key_name                    = aws_key_pair.ssh_key.key_name
    tags = {
        Name = "Jumphost"
    }
    
}

