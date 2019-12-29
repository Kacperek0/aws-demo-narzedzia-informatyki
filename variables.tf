variable "region" {
  description = "Region np. Centralna Europa"
}

variable "ami_WindowsServer2019" {
  description = "AMI Windows Server 2019 w EU-Central-1"
}

variable "instance_type" {
  description = "Typ instancji. T2.micro jest darmowa."
}

variable "tag_prefix" {
  description = "Prefiks tagów"
}
