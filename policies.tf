data "aws_iam_policy_document" "codedeploy-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2-instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "terra_ec2_instance_profile" {
  name = "terra_ec2_instance_profile"
  role = aws_iam_role.ec2_instance_profile_role.name
}

resource "aws_iam_role" "ec2_instance_profile_role" {
  name = "ec2_instance_profile_role"
  assume_role_policy = data.aws_iam_policy_document.ec2-instance-assume-role-policy.json
}

resource "aws_iam_policy" "code_deploy_ec2_s3" {
  policy = file("code_deploy_ec2_s3.json")
  name = "code_deploy_ec2_s3"
}

resource "aws_iam_role_policy_attachment" "code_deploy_ec2_s3_attach" {
  policy_arn = aws_iam_policy.code_deploy_ec2_s3.arn
  role = aws_iam_role.ec2_instance_profile_role.name
}

resource "aws_iam_role" "code_deploy_service_role" {
  name = "code_deploy_service_role"
  assume_role_policy = data.aws_iam_policy_document.codedeploy-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "code_deploy_service_role_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role = aws_iam_role.code_deploy_service_role.name
}