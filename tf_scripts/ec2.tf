data "aws_ami" "latest_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["webapp-ami-*"]
  }
}
