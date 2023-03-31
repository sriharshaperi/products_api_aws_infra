data "aws_iam_policy" "CloudWatchAgentPolicy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "role-ploicy-CW-attach" {
  role       = aws_iam_role.s3_access_role.name
  policy_arn = data.aws_iam_policy.CloudWatchAgentPolicy.arn
}
