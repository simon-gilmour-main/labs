terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket-simong"
    key            = "tf-ec2/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-locks" # optional but recommended
  }
}

provider "aws" {
  region = "eu-west-2"
}

# 🔍 Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# 🔑 Upload your public key to AWS
resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file("/root/.ssh/mykey.pub")
}

# 🔓 Allow SSH access
resource "aws_security_group" "ssh" {
  name = "allow_ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # open for testing
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 🖥️ EC2 instance
resource "aws_instance" "test" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  key_name               = aws_key_pair.mykey.key_name
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name = "terraform-test"
  }
}
