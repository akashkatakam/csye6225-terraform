data "aws_ami" "centos" {
  most_recent = true
  filter {
    name = "name"
    values = ["csye6225*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["self"]
}

resource "aws_security_group" "web_security_group" {
  name = "web_security_group"
  description = "security group of RDS instance"
  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  vpc_id = aws_vpc.terraform-vpc.id
}

resource "aws_security_group" "db_security_group" {
  name = "db_security_group"
  description = "security group of RDS instance"
  ingress {
    from_port = 3306
    protocol = "tcp"
    to_port = 3306
  }
  vpc_id = aws_vpc.terraform-vpc.id
}
resource "aws_instance" "ec2" {
  ami = data.aws_ami.centos.image_id
  instance_type = "t2.micro"
  tags = {
    name = "terra-ec2"
  }
  subnet_id = aws_subnet.subnet1.id
  key_name = var.key_name
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    delete_on_termination = true
    volume_size = 20
  }
  associate_public_ip_address = true
  security_groups = [aws_security_group.web_security_group.id]
  depends_on = [aws_db_instance.terra_rds]
}

resource "aws_db_instance" "terra_rds" {
  instance_class = "db.t2.micro"
  allocated_storage = 5
  storage_type = "gp2"
  engine = "mysql"
  engine_version = "5.7.25"
  multi_az = false
  identifier = "terra-csye"
  username = "csye6225master"
  password = "csye6225password"
  db_subnet_group_name = aws_db_subnet_group.terra_db_subnet_group.name
}

resource "aws_db_subnet_group" "terra_db_subnet_group" {
  subnet_ids = [aws_subnet.subnet2.id,aws_subnet.subnet3.id]
  name = "db_subnet_group"
  description = "subnetgroup for database"
}