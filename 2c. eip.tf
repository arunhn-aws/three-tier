# Elastic-ip-addresses

resource "aws_eip" "nat1" {
  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "NAT 1"
  }

}

resource "aws_eip" "nat2" {
  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "nat2" {
  allocation_id = aws_eip.nat2.id
  subnet_id     = aws_subnet.public2.id

  tags = {
    Name = "NAT 2"
  }

}

