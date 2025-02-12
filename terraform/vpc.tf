resource "aws_eip" "alb" {
  tags = var.default_tags
}

resource "aws_eip" "nat" {
  tags = var.default_tags
}

resource "aws_vpc" "automation" {
  cidr_block           = "10.0.0.0/22"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = var.default_tags
}

resource "aws_internet_gateway" "automation" {
  vpc_id = aws_vpc.automation.id

  tags = var.default_tags
}

resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.automation.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = var.default_tags
}

resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.automation.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true

  tags = var.default_tags
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.automation.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-west-2a"

  tags = var.default_tags
}

resource "aws_nat_gateway" "automation" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_az1.id

  tags = var.default_tags

  depends_on = [aws_internet_gateway.automation]
}

resource "aws_route_table" "private_subnet" {
  vpc_id = aws_vpc.automation.id

  tags = var.default_tags
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private_subnet.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.automation.id
}

resource "aws_route_table" "public_subnet" {
  vpc_id = aws_vpc.automation.id

  tags = var.default_tags
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public_subnet.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.automation.id
}

resource "aws_route_table_association" "public_az1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public_subnet.id
}

resource "aws_route_table_association" "public_az2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public_subnet.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_subnet.id
}
