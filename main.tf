
# Konfiguracja "dostawcy" chmury
provider "aws" {
  region = "eu-central-1"
  profile = "default"
}

# Tworzenie sieci wirtualnej
resource "aws_vpc" "vnet" {
  cidr_block       = "10.10.0.0/16"

  tags = {
    Name = "${var.tag_prefix}-vpc"
  }
}

# Tworzenie subnetu w VPC
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vnet.id
  cidr_block = "10.10.0.0/24"
  depends_on = [aws_internet_gateway.gateway]

  tags = {
    Name = "${var.tag_prefix}-subnet"
  }
}

# Internet gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vnet.id

  tags = {
    Name = "${var.tag_prefix}-gateway"
  }
}

# Elastic IP
resource "aws_eip" "eip" {
  vpc = true

  instance                  = aws_instance.windows_server.id
  depends_on                = [aws_internet_gateway.gateway]

  tags = {
    Name = "${var.tag_prefix}-eip"
  }
}

# Security grupa

resource "aws_security_group" "allow_rdp" {
  name        = "${var.tag_prefix}-allow_rdp"
  description = "Allow rdp traffic"
  vpc_id      = aws_vpc.vnet.id

  tags = {
    Name = "${var.tag_prefix}-nsg"
  }
}

# SG rule

resource "aws_security_group_rule" "rdp" {
  type            = "ingress"
  from_port       = 0
  to_port         = 65535
  protocol        = "tcp"
  cidr_blocks     = ["0.0.0.0/0"]
  #Otwieranie całego pasma oraz wszystkich portów nie jest dobrym rozwiązaniem, jednak ten plik jest czysto pokazowy.

  security_group_id = aws_security_group.allow_rdp.id
}

# Tabela Routingu

resource "aws_route_table" "rtable" {
  vpc_id = aws_vpc.vnet.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "${var.tag_prefix}-main"
  }
}

# Ustawiane TR jako głównej

resource "aws_main_route_table_association" "rtmain" {
  vpc_id         = aws_vpc.vnet.id
  route_table_id = aws_route_table.rtable.id
}

# Instancja EC2
resource "aws_instance" "windows_server" {
  ami           = var.windows_server
  instance_type = var.instance_type
  subnet_id = aws_subnet.subnet.id
  key_name = var.keys
  vpc_security_group_ids = [aws_security_group.allow_rdp.id]

  tags = {
    Name = "${var.tag_prefix}-VM"
  }
}
