
# Konfiguracja "dostawcy" chmury
provider "aws" {
  region = var.region
  profile = "default"
}

# Tworzenie sieci wirtualnej
resource "aws_vpc" "VPC" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "dedicated"

  tags = {
    Name = "${var.tag_prefix}-VPC"
  }
}

# Tworzenie subnetu w VPC
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.10.0.0/24"

  tags = {
    Name = "${var.tag_prefix}-subnet"
  }
}

# Internet gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = "${aws_vpc.VPC.id}"

  tags = {
    Name = "${var.tag_prefix}-gateway"
  }
}

# Network interface
resource "aws_network_interface" "nic" {
  subnet_id   = "${aws_subnet.subnet.id}"

  tags = {
    Name = "${var.tag_prefix}-nic"
  }

# Instancja EC2
resource "aws_instance" "EC2_1" {
  ami           = var.ami_WindowsServer2019
  instance_type = var.instance_type
  subnet_id = aws_subnet.VPC.id

  tags = {
    Name = "${var.tag_prefix}-VM"
  }
}