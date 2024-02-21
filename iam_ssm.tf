resource "aws_iam_role" "ssm_document_execution_role" {
  name               = "SSMDocumentExecutionRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ssm.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "ssm_document_execution_profile" {
  name = "SSMDocumentExecutionProfile"
  role = aws_iam_role.ssm_document_execution_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_document_execution_policy_attachment" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
