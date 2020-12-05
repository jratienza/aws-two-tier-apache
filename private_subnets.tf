#Private Subnets
resource "aws_subnet" "private_subnet_1" {
    vpc_id            = aws_vpc.vpc_ltia.id
    cidr_block        = "172.51.1.0/24"
    availability_zone = "us-east-1a"
    
    tags = {
        Name = "private_subnet_1"
    }
}

resource "aws_subnet" "private_subnet_2" {
    vpc_id            = aws_vpc.vpc_ltia.id
    cidr_block        = "172.51.2.0/24"
    availability_zone = "us-east-1b"
    
    tags = {
        Name = "private_subnet_2"
    }
}

#Route Table - Private subnet to NAT gateway
resource "aws_route_table" "private_nat_rt" {
    vpc_id = aws_vpc.vpc_ltia.id

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.natgw_ltia.id
    }

    tags = {
        Name = "private_nat_rt"
    }
}

#Associate route table to Private Subnet
resource "aws_route_table_association" "nat_rt_assoc1" {
    subnet_id      = aws_subnet.private_subnet_1.id
    route_table_id = aws_route_table.private_nat_rt.id
}

resource "aws_route_table_association" "nat_rt_assoc2" {
    subnet_id      = aws_subnet.private_subnet_2.id
    route_table_id = aws_route_table.private_nat_rt.id
}  

