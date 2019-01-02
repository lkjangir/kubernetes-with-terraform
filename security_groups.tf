resource "aws_security_group" "api-elb-sg" {
  name        = "api-elb.${var.cluster_name}"
  vpc_id      = "${var.vpc_id}"
  description = "Security group for api ELB"

  tags = {
    KubernetesCluster                         = "${var.cluster_name}"
    Name                                      = "api-elb.${var.cluster_name}"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group" "k8s-master" {
  name        = "masters.${var.cluster_name}"
  vpc_id      = "${var.vpc_id}"
  description = "Security group for masters"

  tags = {
    KubernetesCluster                         = "${var.cluster_name}"
    Name                                      = "masters.${var.cluster_name}"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group" "k8s-nodes" {
  name        = "nodes.${var.cluster_name}"
  vpc_id      = "${var.vpc_id}"
  description = "Security group for nodes"

  tags = {
    KubernetesCluster                         = "${var.cluster_name}"
    Name                                      = "nodes.${var.cluster_name}"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_security_group_rule" "all-master-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.k8s-master.id}"
  source_security_group_id = "${aws_security_group.k8s-master.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-master-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.k8s-nodes.id}"
  source_security_group_id = "${aws_security_group.k8s-master.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-node-to-node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.k8s-nodes.id}"
  source_security_group_id = "${aws_security_group.k8s-nodes.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all-nodes-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.k8s-master.id}"
  source_security_group_id = "${aws_security_group.k8s-nodes.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "api-elb-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.api-elb-sg.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-api-elb-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.api-elb-sg.id}"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https-elb-to-master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.k8s-master.id}"
  source_security_group_id = "${aws_security_group.api-elb-sg.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.k8s-master.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = "${aws_security_group.k8s-nodes.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-tcp-1-2379" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.k8s-master.id}"
  source_security_group_id = "${aws_security_group.k8s-nodes.id}"
  from_port                = 1
  to_port                  = 2379
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-2382-4000" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.k8s-master.id}"
  source_security_group_id = "${aws_security_group.k8s-nodes.id}"
  from_port                = 2382
  to_port                  = 4000
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.k8s-master.id}"
  source_security_group_id = "${aws_security_group.k8s-nodes.id}"
  from_port                = 4003
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.k8s-master.id}"
  source_security_group_id = "${aws_security_group.k8s-nodes.id}"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.k8s-master.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = "${aws_security_group.k8s-nodes.id}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
