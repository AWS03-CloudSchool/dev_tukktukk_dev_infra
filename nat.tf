module "nat" {
  source = "int128/nat-instance/aws"
  name   = var.infra_name
  vpc_id = aws_vpc.this.id
  public_subnet = aws_subnet.public[0].id
  private_subnets_cidr_blocks = aws_subnet.private[*].cidr_block
  private_route_table_ids = aws_route_table.private[*].id

}

resource "aws_eip" "nat_dev" {
  network_interface = module.nat.eni_id
  tags = {
    Name = var.infra_name
  }

  depends_on = [ module.nat ]
}