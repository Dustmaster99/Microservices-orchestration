# ==========================================================
# Criação da VPC principal
# ==========================================================
# A VPC (Virtual Private Cloud) é a rede virtual onde toda a
# infraestrutura será criada: EKS, RDS, subnets, etc.

resource "aws_vpc" "main" {

  # CIDR da rede da VPC (ex: 10.0.0.0/16)
  cidr_block = var.vpc_cidr

  # Permite que instâncias dentro da VPC tenham nomes DNS
  enable_dns_hostnames = true

  # Ativa o DNS interno da VPC
  enable_dns_support = true

  # Tags usadas para identificação dos recursos na AWS
  tags = merge(
    {
      Name = "${var.project_name}-vpc"
    },
    var.tags
  )
}


# ==========================================================
# Internet Gateway
# ==========================================================
# O Internet Gateway permite que recursos dentro da VPC
# acessem a internet (ex: load balancer, instâncias públicas).

resource "aws_internet_gateway" "igw" {

  # Associa o gateway à VPC criada acima
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.project_name}-igw"
    },
    var.tags
  )
}


# ==========================================================
# Subnets Públicas
# ==========================================================
# Subnets públicas são usadas para recursos que precisam
# acessar diretamente a internet (ex: load balancer ou ingress).

resource "aws_subnet" "public" {

  # Cria uma subnet para cada elemento da lista public_subnets
  count = length(var.public_subnets)

  # VPC onde a subnet será criada
  vpc_id = aws_vpc.main.id

  # CIDR da subnet (ex: 10.0.1.0/24)
  cidr_block = var.public_subnets[count.index]

  # Zona de disponibilidade da subnet
  availability_zone = var.availability_zones[count.index]

  # Faz com que instâncias recebam IP público automaticamente
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name                     = "${var.project_name}-public-${count.index}"
      "kubernetes.io/role/elb" = "1"
    },
    var.tags
  )
}


# ==========================================================
# Subnets Privadas
# ==========================================================
# Subnets privadas são usadas para recursos internos,
# como nodes do Kubernetes ou bancos de dados.

resource "aws_subnet" "private" {

  # Cria uma subnet para cada elemento da lista private_subnets
  count = length(var.private_subnets)

  # VPC onde a subnet será criada
  vpc_id = aws_vpc.main.id

  # CIDR da subnet
  cidr_block = var.private_subnets[count.index]

  # Zona de disponibilidade da subnet
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name                              = "${var.project_name}-private-${count.index}"
      "kubernetes.io/role/internal-elb" = "1"
    },
    var.tags
  )
}


# ==========================================================
# Elastic IP para NAT Gateway
# ==========================================================
# Cada NAT Gateway precisa de um IP público fixo.
# Esse recurso cria esses IPs.

resource "aws_eip" "nat" {

  # Cria um EIP para cada subnet pública
  count = length(var.public_subnets)

  # Indica que o IP será usado dentro de uma VPC
  domain = "vpc"

  tags = merge(
    {
      Name = "${var.project_name}-eip-nat-${count.index}"
    },
    var.tags
  )
}


# ==========================================================
# NAT Gateway
# ==========================================================
# Permite que recursos nas subnets privadas acessem a internet
# (ex: baixar imagens Docker, updates etc.)
# sem ficarem expostos diretamente.

resource "aws_nat_gateway" "nat" {

  # Cria um NAT Gateway por zona de disponibilidade
  count = length(var.public_subnets)

  # IP público associado ao NAT
  allocation_id = aws_eip.nat[count.index].id

  # Subnet pública onde o NAT será criado
  subnet_id = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name = "${var.project_name}-nat-${count.index}"
    },
    var.tags
  )

  # Garante que o Internet Gateway seja criado antes
  depends_on = [aws_internet_gateway.igw]
}


# ==========================================================
# Route Table Pública
# ==========================================================
# Define as rotas usadas pelas subnets públicas.

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id

  route {

    # Todo tráfego externo (internet)
    cidr_block = "0.0.0.0/0"

    # Enviado para o Internet Gateway
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      Name = "${var.project_name}-public-rt"
    },
    var.tags
  )
}


# ==========================================================
# Associação da Route Table Pública
# ==========================================================
# Conecta cada subnet pública à route table pública.

resource "aws_route_table_association" "public" {

  count = length(var.public_subnets)

  subnet_id = aws_subnet.public[count.index].id

  route_table_id = aws_route_table.public.id
}


# ==========================================================
# Route Tables Privadas
# ==========================================================
# Cada subnet privada usa um NAT Gateway para acessar a internet.

resource "aws_route_table" "private" {

  count = length(var.private_subnets)

  vpc_id = aws_vpc.main.id

  route {

    # Tráfego externo
    cidr_block = "0.0.0.0/0"

    # Enviado para o NAT Gateway
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = merge(
    {
      Name = "${var.project_name}-private-rt-${count.index}"
    },
    var.tags
  )
}


# ==========================================================
# Associação das Route Tables Privadas
# ==========================================================
# Conecta cada subnet privada à sua route table correspondente.

resource "aws_route_table_association" "private" {

  count = length(var.private_subnets)

  subnet_id = aws_subnet.private[count.index].id

  route_table_id = aws_route_table.private[count.index].id
}


# ==========================================================
# criação da subnete para os databases
# ==========================================================
# cria recursos de rede para conectar a base de dados.

resource "aws_subnet" "database" {
  count = length(var.database_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.database_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name = "${var.project_name}-database-${count.index + 1}"
      Tier = "database"
    },
    var.tags
  )
}


# ==========================================================
# Route Tables database
# ==========================================================
# Cada subnet database é associada a uma tabela de rotas

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.project_name}-database-rt"
    },
    var.tags
  )
}


# ==========================================================
# Associação das Route Tables database
# ==========================================================
# Conecta cada subnet database à sua route table correspondente.

resource "aws_route_table_association" "database" {
  count = length(var.database_subnets)

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

