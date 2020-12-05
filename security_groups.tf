 
##Web server security group
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
        security_groups = [aws_security_group.jumphost_sg.id]
        self            = true
    }

    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    vpc_id = aws_vpc.vpc_ltia.id 

    tags = {
        Name = "apache_web_sg"
    }
}

#Jumphost server security group 
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

    tags = {
        Name = "jumphost_sg"
    }
}

#Loadbalancer security group
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