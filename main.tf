# Provider Configuration
provider "aws" {
  region = "eu-west-1" # Replace with your desired AWS region
}

# Security Group for Docker Swarm (No Changes Here)
resource "aws_security_group" "docker_sg" {
  name        = "docker-swarm-sg"
  description = "Security group for Docker Swarm and related services"

  # SSH Access (Port 22)
  ingress {
    description = "Allow SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MySQL Traffic (Port 3306)
  ingress {
    description = "Allow MySQL traffic"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Java Microservice Traffic (Port 8080)
  ingress {
    description = "Allow Java microservice traffic"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Logstash Traffic (Port 5044)
  ingress {
    description = "Allow Logstash traffic"
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Docker Swarm Port 2377
  ingress {
    description = "Docker Swarm Port 2377"
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Docker Swarm Node Communication (Port 7946)
  ingress {
    description = "Docker Swarm Node Communication"
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Docker Swarm Overlay Network (Port 4789)
  ingress {
    description = "Docker Swarm Overlay Network"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP Traffic (Port 80)
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kibana Traffic (Port 5601)
  ingress {
    description = "Allow Kibana traffic"
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Docker Swarm Manager Node
resource "aws_instance" "manager" {
  ami           = "ami-0e9085e60087ce171"
  instance_type = "t2.small"
  key_name      = "docker-swarm-keypair" # Replace with your key pair name
  security_groups = [aws_security_group.docker_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu

              mkdir logs
              touch logs/application.log
              EOF

  tags = {
    Name = "swarm-manager"
  }
}

# Docker Swarm Worker Nodes
resource "aws_instance" "worker" {
  count         = 2
  ami           = "ami-0e9085e60087ce171"
  instance_type = "t2.micro"
  key_name      = "docker-swarm-keypair" # Replace with your key pair name
  security_groups = [aws_security_group.docker_sg.name]

  depends_on = [aws_instance.manager]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "swarm-worker-${count.index + 1}"
  }
}

# Outputs
output "manager_public_ip" {
  description = "Public IP of the Docker Swarm Manager"
  value       = aws_instance.manager.public_ip
}

output "worker_public_ips" {
  description = "Public IPs of the Docker Swarm Workers"
  value       = aws_instance.worker[*].public_ip
}
