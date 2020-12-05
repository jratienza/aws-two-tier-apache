##Public Subnets

resource "aws_subnet" "public_subnet" {
    vpc_id                  = aws_vpc.vpc_ltia.id
    cidr_block              = "172.51.0.0/28"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1a"
    tags = {
        Name = "public_subnet"
    }
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id                  = aws_vpc.vpc_ltia.id
    cidr_block              = "172.51.16.0/28"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1b"
    
    tags = {
        Name = "public_subnet_2"
    }
}

#Public route table
resource "aws_route_table" "public_rt"{
    vpc_id = aws_vpc.vpc_ltia.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_ltia.id
    }

    tags = {
        Name = "public_subnet_route"
    }
}

#Route Table Association to Subnet
resource "aws_route_table_association" "public_rt_assoc" {
    subnet_id      = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc2" {
    subnet_id      = aws_subnet.public_subnet_2.id
    route_table_id = aws_route_table.public_rt.id
}
