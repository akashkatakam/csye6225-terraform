variable "aws_ami" {
  description = "AMIs by region"
  default = {
    us-east-1 = "ami-f1810f86" # ubuntu 14.04 LTS
  }
}
variable "key_name" {
  description = "Enter the key name to access ec2"
  default = "ubuntu"
}