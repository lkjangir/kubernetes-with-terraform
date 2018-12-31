variable "subnet_id_1" {
  type = "string"
  default = "subnet-24d6d362"
}

variable "subnet_id_2" {
  type = "string"
  default = "subnet-b369acd6"
}

variable "vpc_id" {
  type = "string"
  default = "vpc-cd5fb5a8"
}

locals = {
  cluster_name                      = "one.colabit.store"
  master_autoscaling_group_ids      = ["${aws_autoscaling_group.master-us-west-1c-masters-one-colabit-store.id}"]
  master_security_group_ids         = ["${aws_security_group.masters-one-colabit-store.id}"]
  masters_role_arn                  = "${aws_iam_role.masters-one-colabit-store.arn}"
  masters_role_name                 = "${aws_iam_role.masters-one-colabit-store.name}"
  node_autoscaling_group_ids        = ["${aws_autoscaling_group.nodes-one-colabit-store.id}"]
  node_security_group_ids           = ["${aws_security_group.nodes-one-colabit-store.id}"]
  node_subnet_ids                   = ["${var.subnet_id_1}", "${var.subnet_id_2}"]
  nodes_role_arn                    = "${aws_iam_role.nodes-one-colabit-store.arn}"
  nodes_role_name                   = "${aws_iam_role.nodes-one-colabit-store.name}"
  region                            = "us-west-1"
  route_table_private-us-west-1b_id = "${aws_route_table.private-us-west-1b-one-colabit-store.id}"
  route_table_private-us-west-1c_id = "${aws_route_table.private-us-west-1c-one-colabit-store.id}"
  route_table_public_id             = "${aws_route_table.one-colabit-store.id}"
  subnet_us-west-1b_id              = "${var.subnet_id_1}"
  subnet_us-west-1c_id              = "${var.subnet_id_2}"
  subnet_utility-us-west-1b_id      = "${var.subnet_id_1}"
  subnet_utility-us-west-1c_id      = "${var.subnet_id_2}"
  vpc_id                            = "${var.vpc_id}"
}

output "cluster_name" {
  value = "one.colabit.store"
}

output "master_autoscaling_group_ids" {
  value = ["${aws_autoscaling_group.master-us-west-1c-masters-one-colabit-store.id}"]
}

output "master_security_group_ids" {
  value = ["${aws_security_group.masters-one-colabit-store.id}"]
}

output "masters_role_arn" {
  value = "${aws_iam_role.masters-one-colabit-store.arn}"
}

output "masters_role_name" {
  value = "${aws_iam_role.masters-one-colabit-store.name}"
}

output "node_autoscaling_group_ids" {
  value = ["${aws_autoscaling_group.nodes-one-colabit-store.id}"]
}

output "node_security_group_ids" {
  value = ["${aws_security_group.nodes-one-colabit-store.id}"]
}

# output "node_subnet_ids" {
#   value = ["${aws_subnet.us-west-1b-one-colabit-store.id}", "${aws_subnet.us-west-1c-one-colabit-store.id}"]
# }

output "nodes_role_arn" {
  value = "${aws_iam_role.nodes-one-colabit-store.arn}"
}

output "nodes_role_name" {
  value = "${aws_iam_role.nodes-one-colabit-store.name}"
}

output "region" {
  value = "us-west-1"
}

output "route_table_private-us-west-1b_id" {
  value = "${aws_route_table.private-us-west-1b-one-colabit-store.id}"
}

output "route_table_private-us-west-1c_id" {
  value = "${aws_route_table.private-us-west-1c-one-colabit-store.id}"
}

output "route_table_public_id" {
  value = "${aws_route_table.one-colabit-store.id}"
}

# output "subnet_us-west-1b_id" {
#   value = "${aws_subnet.us-west-1b-one-colabit-store.id}"
# }

# output "subnet_us-west-1c_id" {
#   value = "${aws_subnet.us-west-1c-one-colabit-store.id}"
# }

# output "subnet_utility-us-west-1b_id" {
#   value = "${aws_subnet.utility-us-west-1b-one-colabit-store.id}"
# }

# output "subnet_utility-us-west-1c_id" {
#   value = "${aws_subnet.utility-us-west-1c-one-colabit-store.id}"
# }

output "vpc_id" {
  value = "${var.vpc_id}"
}

provider "aws" {
  region = "us-west-1"
  profile = "sds"

}

resource "aws_autoscaling_attachment" "master-us-west-1c-masters-one-colabit-store" {
  elb                    = "${aws_elb.api-one-colabit-store.id}"
  autoscaling_group_name = "${aws_autoscaling_group.master-us-west-1c-masters-one-colabit-store.id}"
}

resource "aws_autoscaling_group" "master-us-west-1c-masters-one-colabit-store" {
  name                 = "master-us-west-1c.masters.one.colabit.store"
  #availability_zones = ["us-west-1b", "us-west-1c"]
  launch_configuration = "${aws_launch_configuration.master-us-west-1c-masters-one-colabit-store.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${var.subnet_id_2}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "one.colabit.store"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-us-west-1c.masters.one.colabit.store"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "master-us-west-1c"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_autoscaling_group" "nodes-one-colabit-store" {
  name                 = "nodes.one.colabit.store"
  launch_configuration = "${aws_launch_configuration.nodes-one-colabit-store.id}"
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = ["${var.subnet_id_1}", "${var.subnet_id_2}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "one.colabit.store"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.one.colabit.store"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
    value               = "nodes"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_ebs_volume" "c-etcd-events-one-colabit-store" {
  availability_zone = "us-west-1c"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                         = "one.colabit.store"
    Name                                      = "c.etcd-events.one.colabit.store"
    "k8s.io/etcd/events"                      = "c/c"
    "k8s.io/role/master"                      = "1"
    "kubernetes.io/cluster/one.colabit.store" = "owned"
  }
}

resource "aws_ebs_volume" "c-etcd-main-one-colabit-store" {
  availability_zone = "us-west-1c"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                         = "one.colabit.store"
    Name                                      = "c.etcd-main.one.colabit.store"
    "k8s.io/etcd/main"                        = "c/c"
    "k8s.io/role/master"                      = "1"
    "kubernetes.io/cluster/one.colabit.store" = "owned"
  }
}

resource "aws_eip" "us-west-1b-one-colabit-store" {
  vpc = true

  tags = {
    KubernetesCluster                         = "one.colabit.store"
    Name                                      = "us-west-1b.one.colabit.store"
    "kubernetes.io/cluster/one.colabit.store" = "owned"
  }
}

resource "aws_eip" "us-west-1c-one-colabit-store" {
  vpc = true

  tags = {
    KubernetesCluster                         = "one.colabit.store"
    Name                                      = "us-west-1c.one.colabit.store"
    "kubernetes.io/cluster/one.colabit.store" = "owned"
  }
}

resource "aws_elb" "api-one-colabit-store" {
  name = "api-one-colabit-store-b5g7s7"
  # availability_zones = ["us-west-1b", "us-west-1c"]
  listener = {
    instance_port     = 443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  security_groups = ["${aws_security_group.api-elb-one-colabit-store.id}"]
  subnets         = ["${var.subnet_id_1}", "${var.subnet_id_2}"]

  health_check = {
    target              = "SSL:443"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }

  idle_timeout = 300

  tags = {
    KubernetesCluster = "one.colabit.store"
    Name              = "api.one.colabit.store"
  }
}

resource "aws_iam_instance_profile" "masters-one-colabit-store" {
  name = "masters.one.colabit.store"
  role = "${aws_iam_role.masters-one-colabit-store.name}"
}

resource "aws_iam_instance_profile" "nodes-one-colabit-store" {
  name = "nodes.one.colabit.store"
  role = "${aws_iam_role.nodes-one-colabit-store.name}"
}

resource "aws_iam_role" "masters-one-colabit-store" {
  name               = "masters.one.colabit.store"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.one.colabit.store_policy")}"
}

resource "aws_iam_role" "nodes-one-colabit-store" {
  name               = "nodes.one.colabit.store"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.one.colabit.store_policy")}"
}

resource "aws_iam_role_policy" "masters-one-colabit-store" {
  name   = "masters.one.colabit.store"
  role   = "${aws_iam_role.masters-one-colabit-store.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_masters.one.colabit.store_policy")}"
}

resource "aws_iam_role_policy" "nodes-one-colabit-store" {
  name   = "nodes.one.colabit.store"
  role   = "${aws_iam_role.nodes-one-colabit-store.name}"
  policy = "${file("${path.module}/data/aws_iam_role_policy_nodes.one.colabit.store_policy")}"
}

resource "aws_key_pair" "kubernetes-one-colabit-store-7b2dbd3b53873a337da0a7ac384099d2" {
  key_name   = "kubernetes.one.colabit.store-7b:2d:bd:3b:53:87:3a:33:7d:a0:a7:ac:38:40:99:d2"
  public_key = "${file("${path.module}/data/aws_key_pair_kubernetes.one.colabit.store-7b2dbd3b53873a337da0a7ac384099d2_public_key")}"
}

resource "aws_launch_configuration" "master-us-west-1c-masters-one-colabit-store" {
  name_prefix                 = "master-us-west-1c.masters.one.colabit.store-"
  image_id                    = "ami-063aa838bd7631e0b"
  instance_type               = "t2.medium"
  # key_name                    = "${aws_key_pair.kubernetes-one-colabit-store-7b2dbd3b53873a337da0a7ac384099d2.id}"
  key_name                    = "openvas"
  iam_instance_profile        = "${aws_iam_instance_profile.masters-one-colabit-store.id}"
  security_groups             = ["${aws_security_group.masters-one-colabit-store.id}"]
  associate_public_ip_address = false
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_master-us-west-1c.masters.one.colabit.store_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 64
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}

resource "aws_launch_configuration" "nodes-one-colabit-store" {
  name_prefix                 = "nodes.one.colabit.store-"
  image_id                    = "ami-063aa838bd7631e0b"
  instance_type               = "t2.small"
  # key_name                    = "${aws_key_pair.kubernetes-one-colabit-store-7b2dbd3b53873a337da0a7ac384099d2.id}"
  key_name                    = "openvas"
  iam_instance_profile        = "${aws_iam_instance_profile.nodes-one-colabit-store.id}"
  security_groups             = ["${aws_security_group.nodes-one-colabit-store.id}"]
  associate_public_ip_address = false
  user_data                   = "${file("${path.module}/data/aws_launch_configuration_nodes.one.colabit.store_user_data")}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }

  enable_monitoring = false
}

# resource "aws_nat_gateway" "us-west-1b-one-colabit-store" {
#   allocation_id = "${aws_eip.us-west-1b-one-colabit-store.id}"
#   subnet_id     = "${aws_subnet.utility-us-west-1b-one-colabit-store.id}"

#   tags = {
#     KubernetesCluster                         = "one.colabit.store"
#     Name                                      = "us-west-1b.one.colabit.store"
#     "kubernetes.io/cluster/one.colabit.store" = "owned"
#   }
# }

# resource "aws_nat_gateway" "us-west-1c-one-colabit-store" {
#   allocation_id = "${aws_eip.us-west-1c-one-colabit-store.id}"
#   subnet_id     = "${aws_subnet.utility-us-west-1c-one-colabit-store.id}"

#   tags = {
#     KubernetesCluster                         = "one.colabit.store"
#     Name                                      = "us-west-1c.one.colabit.store"
#     "kubernetes.io/cluster/one.colabit.store" = "owned"
#   }
# }

# data "aws_route_table" "aws_route_table_id_1" {
#   subnet_id = "${var.subnet_id_1}"
# }

# data "aws_route_table" "aws_route_table_id_2" {
#   subnet_id = "${var.subnet_id_2}"
# }

# resource "aws_route" "0-0-0-0--0" {
#   route_table_id         = "${aws_route_table.one-colabit-store.id}"
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = "igw-ce3bdfab"
# }

# resource "aws_route" "private-us-west-1b-0-0-0-0--0" {
#   route_table_id         = "${aws_route_table.private-us-west-1b-one-colabit-store.id}"
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = "${data.aws_nat_gateway.nat_gateway_id_1.id}"
# }

# resource "aws_route" "private-us-west-1c-0-0-0-0--0" {
#   route_table_id         = "${aws_route_table.private-us-west-1c-one-colabit-store.id}"
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = "${data.aws_nat_gateway.nat_gateway_id_2.id}"
# }

resource "aws_route53_record" "api-one-colabit-store" {
  name = "api.one.colabit.store"
  type = "A"

  alias = {
    name                   = "${aws_elb.api-one-colabit-store.dns_name}"
    zone_id                = "${aws_elb.api-one-colabit-store.zone_id}"
    evaluate_target_health = false
  }

  zone_id = "/hostedzone/Z3OZL4CQM1ZIPC"
}

resource "aws_route_table" "one-colabit-store" {
  vpc_id = "${var.vpc_id}"

  tags = {
    KubernetesCluster                         = "one.colabit.store"
    Name                                      = "one.colabit.store"
    "kubernetes.io/cluster/one.colabit.store" = "owned"
    "kubernetes.io/kops/role"                 = "public"
  }
}

resource "aws_route_table" "private-us-west-1b-one-colabit-store" {
  vpc_id = "${var.vpc_id}"

  tags = {
    KubernetesCluster                         = "one.colabit.store"
    Name                                      = "private-us-west-1b.one.colabit.store"
    "kubernetes.io/cluster/one.colabit.store" = "owned"
    "kubernetes.io/kops/role"                 = "private-us-west-1b"
  }
}

resource "aws_route_table" "private-us-west-1c-one-colabit-store" {
  vpc_id = "${var.vpc_id}"

  tags = {
    KubernetesCluster                         = "one.colabit.store"
    Name                                      = "private-us-west-1c.one.colabit.store"
    "kubernetes.io/cluster/one.colabit.store" = "owned"
    "kubernetes.io/kops/role"                 = "private-us-west-1c"
  }
}

# resource "aws_route_table_association" "private-us-west-1b-one-colabit-store" {
#   subnet_id      = "${var.subnet_id_1}"
#   route_table_id = "${aws_route_table.private-us-west-1b-one-colabit-store.id}"
# }

# # resource "aws_route_table_association" "private-us-west-1c-one-colabit-store" {
# #   subnet_id      = "${aws_subnet.us-west-1c-one-colabit-store.id}"
# #   route_table_id = "${aws_route_table.private-us-west-1c-one-colabit-store.id}"
# # }

# resource "aws_route_table_association" "utility-us-west-1b-one-colabit-store" {
#   subnet_id      = "${var.subnet_id_1}"
#   route_table_id = "${aws_route_table.one-colabit-store.id}"
# }

# resource "aws_route_table_association" "utility-us-west-1c-one-colabit-store" {
#   subnet_id      = "${aws_subnet.utility-us-west-1c-one-colabit-store.id}"
#   route_table_id = "${aws_route_table.one-colabit-store.id}"
# }

resource "aws_security_group" "api-elb-one-colabit-store" {
  name        = "api-elb.one.colabit.store"
  vpc_id      = "${var.vpc_id}"
  description = "Security group for api ELB"

  tags = {
    KubernetesCluster                         = "one.colabit.store"
    Name                                      = "api-elb.one.colabit.store"
    "kubernetes.io/cluster/one.colabit.store" = "owned"
  }
}

resource "aws_security_group" "masters-one-colabit-store" {
  name        = "masters.one.colabit.store"
  vpc_id      = "${var.vpc_id}"
  description = "Security group for masters"

  tags = {
    KubernetesCluster                         = "one.colabit.store"
    Name                                      = "masters.one.colabit.store"
    "kubernetes.io/cluster/one.colabit.store" = "owned"
  }
}

resource "aws_security_group" "nodes-one-colabit-store" {
  name        = "nodes.one.colabit.store"
  vpc_id      = "${var.vpc_id}"
  description = "Security group for nodes"

  tags = {
    KubernetesCluster                         = "one.colabit.store"
    Name                                      = "nodes.one.colabit.store"
    "kubernetes.io/cluster/one.colabit.store" = "owned"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-one-colabit-store.id}"
  source_security_group_id = "${aws_security_group.masters-one-colabit-store.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-one-colabit-store.id}"
  source_security_group_id = "${aws_security_group.masters-one-colabit-store.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.nodes-one-colabit-store.id}"
  source_security_group_id = "${aws_security_group.nodes-one-colabit-store.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-nodes-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-one-colabit-store.id}"
  source_security_group_id = "${aws_security_group.nodes-one-colabit-store.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "api-elb-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.api-elb-one-colabit-store.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-api-elb-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.api-elb-one-colabit-store.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-elb-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-one-colabit-store.id}"
  source_security_group_id = "${aws_security_group.api-elb-one-colabit-store.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.masters-one-colabit-store.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.nodes-one-colabit-store.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-tcp-1-2379" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-one-colabit-store.id}"
  source_security_group_id = "${aws_security_group.nodes-one-colabit-store.id}"
  from_port                = 1
  to_port                  = 2379
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-2382-4000" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-one-colabit-store.id}"
  source_security_group_id = "${aws_security_group.nodes-one-colabit-store.id}"
  from_port                = 2382
  to_port                  = 4000
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-one-colabit-store.id}"
  source_security_group_id = "${aws_security_group.nodes-one-colabit-store.id}"
  from_port                = 4003
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.masters-one-colabit-store.id}"
  source_security_group_id = "${aws_security_group.nodes-one-colabit-store.id}"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.masters-one-colabit-store.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.nodes-one-colabit-store.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# resource "aws_subnet" "us-west-1b-one-colabit-store" {
#   vpc_id            = "${var.vpc_id}"
#   cidr_block        = "172.31.32.0/19"
#   availability_zone = "us-west-1b"

#   tags = {
#     KubernetesCluster                         = "one.colabit.store"
#     Name                                      = "us-west-1b.one.colabit.store"
#     SubnetType                                = "Private"
#     "kubernetes.io/cluster/one.colabit.store" = "owned"
#     "kubernetes.io/role/internal-elb"         = "1"
#   }
# }

# resource "aws_subnet" "us-west-1c-one-colabit-store" {
#   vpc_id            = "${var.vpc_id}"
#   cidr_block        = "172.31.64.0/19"
#   availability_zone = "us-west-1c"

#   tags = {
#     KubernetesCluster                         = "one.colabit.store"
#     Name                                      = "us-west-1c.one.colabit.store"
#     SubnetType                                = "Private"
#     "kubernetes.io/cluster/one.colabit.store" = "owned"
#     "kubernetes.io/role/internal-elb"         = "1"
#   }
# }

# resource "aws_subnet" "utility-us-west-1b-one-colabit-store" {
#   vpc_id            = "${var.vpc_id}"
#   cidr_block        = "172.31.0.0/22"
#   availability_zone = "us-west-1b"

#   tags = {
#     KubernetesCluster                         = "one.colabit.store"
#     Name                                      = "utility-us-west-1b.one.colabit.store"
#     SubnetType                                = "Utility"
#     "kubernetes.io/cluster/one.colabit.store" = "owned"
#     "kubernetes.io/role/elb"                  = "1"
#   }
# }

# resource "aws_subnet" "utility-us-west-1c-one-colabit-store" {
#   vpc_id            = "${var.vpc_id}"
#   cidr_block        = "172.31.4.0/22"
#   availability_zone = "us-west-1c"

#   tags = {
#     KubernetesCluster                         = "one.colabit.store"
#     Name                                      = "utility-us-west-1c.one.colabit.store"
#     SubnetType                                = "Utility"
#     "kubernetes.io/cluster/one.colabit.store" = "owned"
#     "kubernetes.io/role/elb"                  = "1"
#   }
# }

# data "aws_subnet" "subnet_id_1" {
#   id = "${var.subnet_id_1}"
# }

# data "aws_subnet" "subnet_id_2" {
#   id = "${var.subnet_id_2}"
# }

terraform = {
  required_version = ">= 0.9.3"
}
