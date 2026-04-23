# 1. Le VPC (Le réseau privé virtuel)
resource "aws_vpc" "k3s_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "k3s-vpc"
  }
}

# 2. Le Subnet Public (L'endroit où sera notre serveur)
resource "aws_subnet" "k3s_subnet" {
  vpc_id                  = aws_vpc.k3s_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true # Indispensable pour avoir une IP publique
  availability_zone       = "eu-west-3a"

  tags = {
    Name = "k3s-subnet-public"
  }
}

# 3. L'Internet Gateway (La porte de sortie vers le web)
resource "aws_internet_gateway" "k3s_gw" {
  vpc_id = aws_vpc.k3s_vpc.id

  tags = {
    Name = "k3s-igw"
  }
}

# 4. La Table de Routage (Le GPS du réseau)
resource "aws_route_table" "k3s_rt" {
  vpc_id = aws_vpc.k3s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"                    # Tout le trafic sortant...
    gateway_id = aws_internet_gateway.k3s_gw.id # ...passe par la passerelle internet
  }

  tags = {
    Name = "k3s-route-table"
  }
}

# 5. Association de la Table de Routage au Subnet
resource "aws_route_table_association" "k3s_rta" {
  subnet_id      = aws_subnet.k3s_subnet.id
  route_table_id = aws_route_table.k3s_rt.id
}
# 6. Le Groupe de Sécurité (Le Pare-feu)
resource "aws_security_group" "k3s_sg" {
  name        = "k3s-security-group"
  description = "Autoriser SSH et le trafic K3s" # <--- L'ancienne description est ici
  vpc_id      = aws_vpc.k3s_vpc.id

  # Port 22 pour le SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Port 6443 pour l'API Kubernetes
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # --- AJOUTS RÉUSSIS (Le trafic passera par ici) ---
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acces HTTP standard"
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acces aux applications via NodePort"
  }

  # Autoriser tout le trafic sortant
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "k3s-sg"
  }
}