resource "aws_vpc" "test-vpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "test-subnet" {
  vpc_id                  = aws_vpc.test-vpc.id
  availability_zone       = var.azs[0]
  cidr_block              = var.vpc_cidr

  tags = {
    Name = "test-subnet"
  }
}