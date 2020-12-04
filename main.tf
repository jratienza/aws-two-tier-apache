provider "aws" {
    version = "~> 2.65"
    region  = "us-east-1"
}

resource "aws_vpc" "vpc_ltia" {
    cidr_block = "172.51.0.0/16"
    tags       = {
        Name = "vpc_ltia"
    }
}

resource "aws_internet_gateway" "igw_ltia" {
     vpc_id   = aws_vpc.vpc_ltia.id
     tags {
        Name = "igw_ltia"
     }
}

resource "aws_route_table" "public_rt"{
    vpc_id = aws_vpc.vpc_ltia.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_ltia.id
    }

    tags {
        Name = "public_subnet_route"
    }
}

resource "aws_route_table_association" "public_rt_assoc" {
    subnet_id      = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_subnet" "public_subnet" {
    vpc_id                  = aws_vpc.vpc_ltia.id
    cidr_block              = "172.51.0.0/28"
    map_public_ip_on_launch = true
    
    tags = {
        Name = "public_subnet"
    }
}

resource "aws_subnet" "private_subnet_1" {
    vpc_id            = aws_vpc.vpc_ltia.id
    cidr_block        = "172.51.1.0/24"
    availability_zone = "us-east-1a"
    tags{
        Name = "private_subnet_1"
    }
}

resource "aws_subnet" "private_subnet_2" {
    vpc_id            = aws_vpc.vpc_ltia.id
    cidr_block        = "172.51.2.0/24"
    availability_zone = "us-east-1b"
    tags{
        Name = "private_subnet_2"
    }
}

resource "aws_eip" "nat_eip" {
    vpc = true
}

resource "aws_nat_gateway" "natgw_ltia" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id     = aws_subnet.public_subnet.id
    tags = {
        Name = "natgw_ltia"
    }
}

resource "aws_route_table" "private_nat_rt" {
    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.natgw_ltia.id
    }

    tags {
        Name = "private_nat_rt"
    }
}

resource "aws_route_table_association" "nat_rt_assoc1" {
    subnet_id      = aws_subnet.private_subnet_1.id
    route_table_id = aws_route_table.private_nat_rt.id
}

resource "aws_route_table_association" "nat_rt_assoc2" {
    subnet_id      = aws_subnet.private_subnet_2.id
    route_table_id = aws_route_table.private_nat_rt.id
}   

resource "aws_security_group" "apache_sg"{
    name        = "apache_web_sg"
    description = "Allow incoming HTTP connections and SSH from jumphost"

    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        security_groups = [aws_security_group.elb_sg.id]
    }
    
    ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        security_groups = [aws_security_group.jumphost_sg.id, aws_security_group.apache_sg.id]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    vpc_id = aws_vpc.vpc_ltia.id 

    tags {
        Name = "apache_web_sg"
    }
}

resource "aws_security_group" "jumphost_sg"{
    name        = "jumphost_sg"
    description = "Allow incoming SSH to Jumphost"
    
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = aws_vpc.vpc_ltia.id 

    tags {
        Name = "jumphost_sg"
    }
}

resource "aws_security_group" "elb_sg"{
    name        = "elb_sg"
    description = "Allow incoming http requests to ELB"

    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
    }
    
    ingress {
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        ipv6_cidr_blocks = ["::/0"]
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    vpc_id = aws_vpc.vpc_ltia.id 

    tags = {
        Name = "elb_sg"
    }
}

resource "aws_key_pair" "ssh_key" {
    key_name = "instance_key"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCoQjEDQZiJXS+Jasovuy7hkT+zpyoHUShox2SvUk5fWs8raJAr0t2Wjq2N9ksO93B+OXKPnpLh50hClXHE5g6l31zwgLsklY5CRLsbBaBrDjSbOCDr79FapWSxzJ4axsyAN3S7X1R5jT+MAE/dWuT+piQSnKdRsS/zHRWkA/jBh7dt0S/DSlrB+yd/Ry6QbrX7lWb1dm9O5HJgqUjaAca2VFwA6thEdzf3WLhHYn5u63K3ua7IjBe+MDcMNXmMCEQIlHdz12pqaTj0xtVzqoO2mh62DiaO1XqmKl6HnNju45jMWzv49QCnU38ZCktvvW2nx0nzskQblKURVFK49nY3"
}

resource "aws_instance" "apache1" {
    instance_type          = "t2.micro"
    ami                    = "ami-0885b1f6bd170450c"
    subnet_id              = aws_subnet.private_subnet_1.id
    vpc_security_group_ids = [ aws_security_group.apache_sg.id ]
    key_name               = aws_key_pair.ssh_key.key_name
    user_data              = "${file("install_apache.sh")}"
    tags {
        Name = "Apache1"
    }
}


resource "aws_instance" "apache2" {
    instance_type          = "t2.micro"
    ami                    = "ami-0885b1f6bd170450c"
    subnet_id              = aws_subnet.private_subnet_2.id
    vpc_security_group_ids = [ aws_security_group.apache_sg.id ]
    key_name               = aws_key_pair.ssh_key.key_name
    user_data              = "${file("install_apache.sh")}"
    tags {
        Name = "Apache1"
    }
}

resource "aws_instance" "Jumphost" {
    instance_type               = "t2.micro"
    ami                         = "ami-0885b1f6bd170450c"
    subnet_id                   = aws_subnet.public_subnet.id
    associate_public_ip_address = true
    vpc_security_group_ids      = [ aws_security_group.jumphost_sg.id ]
    key_name                    = aws_key_pair.ssh_key.key_name
    tags {
        Name = "Jumphost"
    }
    
}

resource "aws_elb" "elb" {
    name            = "elb-ltia"
    subnets         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups = [ aws_security_group.elb_sg.id ]
    instances       = [aws_instance.apache1.id, aws_instance.apache2.id]
    listener {
        instance_port     = 80
        instance_protocol = "http"
        lb_port           = 80
        lb_protocol       = "http"
    }
}