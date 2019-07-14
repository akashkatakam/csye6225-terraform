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
resource "aws_instance" "ec2" {
  ami = data.aws_ami.centos.id
  instance_type = "t2.micro"
  tags ={
    name = "terra-ec2"
  }
  subnet_id = aws_subnet.subnet1.id
}