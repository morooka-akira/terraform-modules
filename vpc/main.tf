# ============================= README ======================================
# vpc リソースの作成
# var.az_count 分のprivateとpublicのsubnetを作成する 
# ===========================================================================
resource "aws_vpc" "main" {
  cidr_block            = var.vpc_cidr_block
  enable_dns_hostnames  = false
  tags = {
    "Name" = "${var.name_prefix} vpc"
  }
}

# ============================= public subnet ======================================
data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 1)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id
  tags = {
    "Name" = "${var.name_prefix} public subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = var.name_prefix
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = var.name_prefix
  }
}

resource "aws_route_table_association" "route_table_association" {
  count          = 1
  subnet_id      = element(aws_subnet.public.*.id, 0)
  route_table_id = aws_route_table.route_table.id
}

# ============================= private subnet ======================================
resource "aws_subnet" "private" {
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + var.az_count + 1)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main.id
  tags = {
    "Name" = "${var.name_prefix} private subnet"
  }
}

resource "aws_eip" "nat_gateway" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]

  tags = {
    "Name" = "${var.name_prefix} nat"
  }
}

resource "aws_nat_gateway" "default" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    "Name" = var.name_prefix
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "${var.name_prefix} private nat"
  }
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  nat_gateway_id         = aws_nat_gateway.default.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private" {
  subnet_id      = element(aws_subnet.private.*.id, 0)
  route_table_id = aws_route_table.private.id
}