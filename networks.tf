resource "aws_vpc" "vpc_ltia" {
    cidr_block = "172.51.0.0/16"
    
    tags = {
        Name = "vpc_ltia"
    }
}

resource "aws_internet_gateway" "igw_ltia" {
     vpc_id   = aws_vpc.vpc_ltia.id
     
     tags = {
        Name = "igw_ltia"
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