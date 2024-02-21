
# Listout AZs

data "aws_availability_zones" "available" {
  state = "available"

}


# PUBLIC SUBNETs

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  cidr_block              = var.cidr_pub_sub_1
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "Public-Web-Subnet-AZ-1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  cidr_block              = var.cidr_pub_sub_2
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "Public-Web-Subnet-AZ-2"

  }
}


#Private-App-Subnet

resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidr_pri_sub_1
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "Private-App-Subnet-AZ-1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidr_pri_sub_2
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "Private-App-Subnet-AZ-1"
  }

}

# Private-DB-Subnet-AZ

resource "aws_subnet" "private_db_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidr_pri_data_sub_1
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "Private-DB-Subnet-AZ-1"
  }
}

resource "aws_subnet" "private_db_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidr_pri_data_sub_2
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "Private-DB-Subnet-AZ-2"
  }

}