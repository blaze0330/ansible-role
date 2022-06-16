//This Terraform Template creates 2 Machines on EC2 with the following configuration:
//Ansible Machines will run on Amazon Linux 2, Red Hat Enterprise Linux 8 with a security group
//allowing SSH (22), HTTP (80) and (8080) connections from anywhere.
//User needs to select appropriate variables form "tfvars" file when launching the instance.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "terraform-env-bucket"
    key    = "backend/jenkins/ansible/main.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
  # profile = "default"
  #  secret_key = var.aws_access_key 
  #  access_key = var.aws_secret_key
}

resource "aws_instance" "nodes" {
  ami                    = element(var.myami, count.index)
  instance_type          = var.instancetype
  count                  = var.num
  key_name               = var.mykey
  vpc_security_group_ids = [aws_security_group.tf-sec-gr.id]
  tags = {
    Name = element(var.tags, count.index)
  }
}

resource "aws_security_group" "tf-sec-gr" {
  name = var.mysecgr
  tags = {
    Name = var.mysecgr
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Configure the control node to run Ansible
resource "null_resource" "config" {
  depends_on = [aws_instance.nodes[0]]
  connection {
    host        = aws_instance.nodes[0].public_ip
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/${var.mykeypem}")
  }

  provisioner "file" {
    source      = "./ansible.cfg"
    destination = "/home/ec2-user/.ansible.cfg"
  }

  provisioner "file" {
    source      = "~/.ssh/${var.mykeypem}"
    destination = "/home/ec2-user/${var.mykeypem}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname Control-Node",
      "sudo yum update -y",
      "sudo yum install -y git",
      "sudo yum install -y python3",
      "pip3 install --user ansible",
      "echo [servers] > inventory",
      # Write the IP address of the managed node to inventory
      "echo jenkins_server_1 ansible_host=${aws_instance.nodes[1].private_ip}  ansible_ssh_private_key_file=~/${var.mykeypem}  ansible_user=ec2-user >> inventory",
      "chmod 400 ${var.mykeypem}"
    ]
  }
}

output "control_node_ip" {
  value = aws_instance.nodes[0].public_ip
}

output "privates" {
  value = aws_instance.nodes.*.private_ip
}
