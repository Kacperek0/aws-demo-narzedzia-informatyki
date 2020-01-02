
# Konfiguracja "dostawcy" chmury
provider "aws" {
  region = "eu-central-1"
  profile = "default"
}

# Tworzenie sieci wirtualnej
resource "aws_vpc" "VPC" {
  cidr_block       = "10.10.0.0/16"

  tags = {
    Name = "${var.tag_prefix}-VPC"
  }
}

# Tworzenie subnetu w VPC
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.10.0.0/24"
  depends_on = [aws_internet_gateway.gateway]

  tags = {
    Name = "${var.tag_prefix}-subnet"
  }
}

# Internet gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "${var.tag_prefix}-gateway"
  }
}

# Network interface
resource "aws_network_interface" "nic" {
  subnet_id   = aws_subnet.subnet.id

  attachment {
    instance     = aws_instance.EC2_1.id
    device_index = 1
  }

  tags = {
    Name = "${var.tag_prefix}-nic"
  }
}

# elastic IP
resource "aws_eip" "eip" {
  vpc = true

  instance                  = aws_instance.EC2_1.id
  depends_on                = [aws_internet_gateway.gateway]

  tags = {
    Name = "${var.tag_prefix}-eip"
  }
}

# NAT Gateway
# resource "aws_nat_gateway" "gw" {
#   allocation_id = "default"
#   subnet_id     = aws_subnet.subnet.id

#   tags = {
#     Name = "${var.tag_prefix}-NAT"
#   }
# }


# Instancja EC2
resource "aws_instance" "EC2_1" {
  ami           = var.windows_server
  instance_type = var.instance_type
  subnet_id = aws_subnet.subnet.id
  key_name = "kacper_ubuntuserver"

  tags = {
    Name = "${var.tag_prefix}-VM"
  }
}
