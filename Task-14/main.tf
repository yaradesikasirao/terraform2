resource "aws_instance" "this" {
  ami                         = "ami-0a695f0d95cefc163"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  #availability_zone =  "us-east-2"
  key_name        = "kasi"
  tenancy         = "default"
  subnet_id       = aws_subnet.db[0].id
  security_groups = [aws_security_group.sg4.id]
  user_data                   = file("apache.sh")

    
    depends_on = [
      aws_security_group.sg4
    ]

  provisioner "local-exec" {
    command = "echo hello , kasi >> private_ips.txt"
  }

  tags = {
    Name = "ram"
  }

}

resource "aws_vpc" "kasi4" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "kasi4"
  }
}

resource "aws_subnet" "db" {
  count = 2
  vpc_id            = aws_vpc.kasi4.id
  cidr_block        = cidrsubnet("10.0.0.0/16" , 8 , count.index )
  availability_zone = "${var.region}${var.zones[count.index]}"
  tags = {
    Name = "db${count.index + 1}"
  }
}


resource "aws_security_group" "sg4" {
  name        = "sg4"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.kasi4.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
    ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "sg4"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.kasi4.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.kasi4.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}


resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.db[0].id
  route_table_id = aws_route_table.rt.id

}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.db[1].id
  route_table_id = aws_route_table.rt.id

}


