# 1. On enregistre ta clé publique sur AWS
resource "aws_key_pair" "k3s_key" {
  key_name   = "k3s-key"
  public_key = file("k3s-key.pub")
}

# 2. On crée le serveur EC2
resource "aws_instance" "k3s_server" {
  ami           = "ami-00c71bd4d220aa22a" # Ubuntu 22.04 LTS à Paris (eu-west-3)
  instance_type = "t3.small"             # 2 vCPU, 4GB RAM comme recommandé

  subnet_id              = aws_subnet.k3s_subnet.id
  vpc_security_group_ids = [aws_security_group.k3s_sg.id]
  key_name               = aws_key_pair.k3s_key.key_name
  # --- LE CERVEAU : SCRIPT D'INSTALLATION AUTO ---
  user_data = <<-EOF
              #!/bin/bash
              # Mise à jour système
              apt-get update -y
              
              # Installation de K3s (Version légère)
              curl -sfL https://get.k3s.io | sh -
              
              # On ajuste les droits pour que kubectl soit accessible sans sudo
              chmod 644 /etc/rancher/k3s/k3s.yaml
              EOF
  tags = {
    Name = "k3s-master-node"
  } 
}

# mon adresse ip publique est: 35.180.24.145:32319