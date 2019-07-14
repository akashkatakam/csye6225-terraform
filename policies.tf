//resource "aws_iam_user_policy" "lb_ro" {
//  name = "CircleCI-Upload-To-S3"
//  user = "circleci"
//
//  policy = <<EOF
//{
//  "Version": "2012-10-17",
//  "Statement": [
//            {
//              "Effect": "Allow",
//              "Action": [
//                "s3:PutObject",
//                "s3:ListBucket"
//              ],
//              "Resource": [
//                {
//                  "Fn::Join": [
//                    "",
//                    [
//                      "arn:aws:s3:::code-deploy.",
//                      {
//                        "Ref": "S3Bucket"
//                      },
//                      "
//"
//                    ]
//                  ]
//                },
//                {
//                  "Fn::Join": [
//                    "",
//                    [
//                      "arn:aws:s3:::code-deploy.",
//                      {
//                        "Ref": "S3Bucket"
//                      }
//                    ]
//                  ]
//                }
//              ]
//            }
//          ]
//}
//EOF
//}
