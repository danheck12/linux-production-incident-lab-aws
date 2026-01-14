provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

# --- IAM role for SSM ---
resource "aws_iam_role" "ssm_role" {
  name = "${var.project}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.project}-ec2-profile"
  role = aws_iam_role.ssm_role.name
}

# --- Default VPC + subnet ---
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  subnet_id = element(data.aws_subnets.default.ids, 0)
}

# --- Security Group ---
resource "aws_security_group" "lab_sg" {
  name        = "${var.project}-sg"
  description = "Linux incident lab SG"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH from your IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.project}-sg" })
}

# --- SSH Key ---
resource "aws_key_pair" "lab_key" {
  key_name   = "${var.project}-key"
  public_key = file(var.ssh_public_key_path)
}

# --- EC2 ---
resource "aws_instance" "lab" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = local.subnet_id
  vpc_security_group_ids      = [aws_security_group.lab_sg.id]
  associate_public_ip_address = true

  key_name             = aws_key_pair.lab_key.key_name
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  root_block_device {
    volume_size = var.root_volume_gb
    volume_type = "gp3"
  }

  user_data = file("${path.module}/userdata.sh")

  tags = merge(var.tags, { Name = "${var.project}-ec2" })
}

# --- Extra EBS volume ---
resource "aws_ebs_volume" "extra" {
  availability_zone = aws_instance.lab.availability_zone
  size              = var.extra_volume_gb
  type              = "gp3"

  tags = merge(var.tags, { Name = "${var.project}-extra-ebs" })
}

resource "aws_volume_attachment" "extra_attach" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.extra.id
  instance_id = aws_instance.lab.id
}
