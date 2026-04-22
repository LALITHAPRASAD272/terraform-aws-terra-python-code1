resource "aws_instance" "app" {
  ami           = "ami-0aa31b568c1e8d622"
  instance_type = "t3.micro"

  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  key_name = var.key_name

  depends_on = [aws_db_instance.mysql]

  tags = {
    Name = "prasadAppServer"
  }
}

resource "null_resource" "app_deploy" {

  depends_on = [aws_instance.app]

  # 🔥 Force re-run on every apply (optional but useful)
  triggers = {
    always_run = timestamp()
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("prasad-key.pem")
    host        = aws_instance.app.public_ip
  }

  # Copy app files
  provisioner "file" {
    source      = "app/"
    destination = "/home/ec2-user/"
  }

 provisioner "remote-exec" {
  inline = [

    # ---------------- INSTALL ----------------
    "sudo dnf update -y",
    "sudo dnf install python3-pip -y",
    "pip3 install flask flask-sqlalchemy pymysql gunicorn",

    # ---------------- GLOBAL ENV (FOR SSH ALSO) ----------------
    "echo 'export DB_HOST=${aws_db_instance.mysql.address}' >> /home/ec2-user/.bashrc",
    "echo 'export DB_USER=admin' >> /home/ec2-user/.bashrc",
    "echo 'export DB_PASSWORD=Admin1234!' >> /home/ec2-user/.bashrc",
    "echo 'export DB_NAME=studentdb' >> /home/ec2-user/.bashrc",

    # ---------------- CREATE SYSTEMD SERVICE ----------------
    "echo '[Unit]' | sudo tee /etc/systemd/system/flaskapp.service",
    "echo 'Description=Flask App' | sudo tee -a /etc/systemd/system/flaskapp.service",
    "echo 'After=network.target' | sudo tee -a /etc/systemd/system/flaskapp.service",

    "echo '[Service]' | sudo tee -a /etc/systemd/system/flaskapp.service",
    "echo 'User=ec2-user' | sudo tee -a /etc/systemd/system/flaskapp.service",
    "echo 'WorkingDirectory=/home/ec2-user' | sudo tee -a /etc/systemd/system/flaskapp.service",

    # 🔥 ENV FOR SYSTEMD (APP)
    "echo 'Environment=DB_HOST=${aws_db_instance.mysql.address}' | sudo tee -a /etc/systemd/system/flaskapp.service",
    "echo 'Environment=DB_USER=admin' | sudo tee -a /etc/systemd/system/flaskapp.service",
    "echo 'Environment=DB_PASSWORD=Admin1234!' | sudo tee -a /etc/systemd/system/flaskapp.service",
    "echo 'Environment=DB_NAME=studentdb' | sudo tee -a /etc/systemd/system/flaskapp.service",

    # 🔥 CORRECT GUNICORN PATH + PORT FIX
    "echo 'ExecStart=/home/ec2-user/.local/bin/gunicorn -w 2 -b 0.0.0.0:5000 app:app' | sudo tee -a /etc/systemd/system/flaskapp.service",

    "echo 'Restart=always' | sudo tee -a /etc/systemd/system/flaskapp.service",

    "echo '[Install]' | sudo tee -a /etc/systemd/system/flaskapp.service",
    "echo 'WantedBy=multi-user.target' | sudo tee -a /etc/systemd/system/flaskapp.service",

    # ---------------- START SERVICE ----------------
    "sudo systemctl daemon-reload",
    "sudo systemctl enable flaskapp",
    "sudo systemctl restart flaskapp"
  ]
}
}