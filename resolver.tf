resource "aws_route53_resolver_endpoint" "ucfs_resolver" {
  count     = local.peer_with_ucfs_london[local.environment] ? 1 : 0
  name      = "ucfs_resolver"
  direction = "OUTBOUND"

  security_group_ids = [aws_security_group.k2hb_common.id]

  ip_address {
    subnet_id = local.ingest_subnets.id[0]
  }

  ip_address {
    subnet_id = local.ingest_subnets.id[1]
  }

  ip_address {
    subnet_id = local.ingest_subnets.id[2]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "ucfs_resolver"
    },
  )
}

resource "aws_route53_resolver_rule" "ucfs_london_resolver_rule" {
  count                = local.peer_with_ucfs_london[local.environment] ? 1 : 0
  domain_name          = local.ucfs_london_domains[local.environment]
  name                 = "ucfs_london_resolver_rule"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.ucfs_resolver[0].id

  target_ip {
    ip = element(local.ucfs_london_nameservers[local.environment], 0)
  }

  target_ip {
    ip = element(local.ucfs_london_nameservers[local.environment], 1)
  }

  tags = merge(
    local.common_tags,
    {
      Name = "ucfs_london_resolver_rule"
    },
  )
}

resource "aws_route53_resolver_rule_association" "ucfs_london_resolver_rule_association" {
  count            = local.peer_with_ucfs_london[local.environment] ? 1 : 0
  resolver_rule_id = aws_route53_resolver_rule.ucfs_london_resolver_rule[0].id
  vpc_id           = local.ingest_vpc_id
}
