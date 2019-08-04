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
  description = "security group of EC2 instance"
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
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
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
    Name = "terra-ec2"
  }
  subnet_id = aws_subnet.subnet1.id
  key_name = var.key_name
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_type = "gp2"
    delete_on_termination = true
    volume_size = 20
  }
  iam_instance_profile = aws_iam_instance_profile.terra_ec2_instance_profile.name
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.web_security_group.id]
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

resource "aws_dynamodb_table" "dynamoDb" {
  hash_key = "email"
  name = "terra-csy6225"
  attribute {
    name = "email"
    type = "S"
  }
  ttl {
    attribute_name = "TimeToLive"
    enabled = true
  }
  read_capacity = 5
  write_capacity = 5
}

resource "aws_codedeploy_app" "code_deploy_application" {
  name = "csye6225-terra"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "code_deploy_deployment_group" {
  app_name = aws_codedeploy_app.code_deploy_application.name
  deployment_group_name = "csye6225-webapp-deployment-terra"
  service_role_arn = aws_iam_role.code_deploy_service_role.arn
  auto_rollback_configuration {
    enabled = true
    events = ["DEPLOYMENT_FAILURE"]
  }
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type = "IN_PLACE"
  }
  ec2_tag_filter {
    type = "KEY_AND_VALUE"
    key = "Name"
    value = "terra-ec2"
  }
}