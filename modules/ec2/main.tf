data "aws_ami" "windows" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base-*"]
  }
}

resource "aws_security_group" "sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
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

resource "aws_instance" "app" {
  count         = 2
  ami           = data.aws_ami.windows.id
  instance_type = var.instance_type
  subnet_id     = var.subnet_ids[count.index]
  vpc_security_group_ids = [aws_security_group.sg.id]

  user_data = <<-EOF
<powershell>
Install-WindowsFeature -name Web-Server -IncludeManagementTools
Start-Service W3SVC

$html = "<h1>Hello from Windows ${count.index}</h1>"
Set-Content -Path "C:\\inetpub\\wwwroot\\index.html" -Value $html

iisreset
</powershell>
EOF

  tags = {
    Name = "windows-${count.index}"
  }
}