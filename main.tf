

locals = {
  cluster_name                      = "${var.cluster_name}"
  master_autoscaling_group_ids      = ["${aws_autoscaling_group.k8s-master.id}"]
  master_security_group_ids         = ["${aws_security_group.k8s-master.id}"]
  masters_role_arn                  = "${aws_iam_role.masters-iam-role.arn}"
  masters_role_name                 = "${aws_iam_role.masters-iam-role.name}"
  node_autoscaling_group_ids        = ["${aws_autoscaling_group.k8s-nodes.id}"]
  node_security_group_ids           = ["${aws_security_group.k8s-nodes.id}"]
  node_subnet_ids                   = ["${var.subnet_id_1}", "${var.subnet_id_2}"]
  nodes_role_arn                    = "${aws_iam_role.k8s-nodes.arn}"
  nodes_role_name                   = "${aws_iam_role.k8s-nodes.name}"
  region                            = "${var.region}"
  subnet_us-west-1b_id              = "${var.subnet_id_1}"
  subnet_us-west-1c_id              = "${var.subnet_id_2}"
  subnet_utility-us-west-1b_id      = "${var.subnet_id_1}"
  subnet_utility-us-west-1c_id      = "${var.subnet_id_2}"
  vpc_id                            = "${var.vpc_id}"

}

resource "aws_ebs_volume" "c-etcd-events-volume" {
  availability_zone = "us-west-1c"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                         = "${var.cluster_name}"
    Name                                      = "c.etcd-events.${var.cluster_name}"
    "k8s.io/etcd/events"                      = "c/c"
    "k8s.io/role/master"                      = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_ebs_volume" "c-etcd-main-volume" {
  availability_zone = "us-west-1c"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                         = "${var.cluster_name}"
    Name                                      = "c.etcd-main.${var.cluster_name}"
    "k8s.io/etcd/main"                        = "c/c"
    "k8s.io/role/master"                      = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_elb" "api-elb-k8s" {
  name = "api-${replace(var.cluster_name, ".", "-")}"
  listener = {
    instance_port     = 443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  security_groups = ["${aws_security_group.api-elb-sg.id}"]
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
    KubernetesCluster = "${var.cluster_name}"
    Name              = "api.${var.cluster_name}"
  }
}

resource "aws_iam_instance_profile" "k8s-master" {
  name = "masters.${var.cluster_name}"
  role = "${aws_iam_role.masters-iam-role.name}"
}

resource "aws_iam_instance_profile" "k8s-nodes" {
  name = "nodes.${var.cluster_name}"
  role = "${aws_iam_role.k8s-nodes.name}"
}

resource "aws_iam_role" "masters-iam-role" {
  name               = "masters.${var.cluster_name}"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_masters.policy")}"
}

resource "aws_iam_role" "k8s-nodes" {
  name               = "nodes.${var.cluster_name}"
  assume_role_policy = "${file("${path.module}/data/aws_iam_role_nodes.policy")}"
}

data "template_file" "aws_iam_role_policy_masters_policy" {
  template = "${file("${path.module}/data/aws_iam_role_policy_masters.policy")}"

  vars {
    cluster_name = "${var.cluster_name}"
    s3_bucket = "${var.s3_bucket}"
    r53_zone_id = "${var.r53_zone_id}"
  }
}

resource "aws_iam_role_policy" "k8s-master" {
  name   = "masters.${var.cluster_name}"
  role   = "${aws_iam_role.masters-iam-role.name}"
  policy = "${data.template_file.aws_iam_role_policy_masters_policy.rendered}"
}

data "template_file" "aws_iam_role_policy_nodes_policy" {
  template = "${file("${path.module}/data/aws_iam_role_policy_nodes.policy")}"

  vars {
    cluster_name = "${var.cluster_name}"
    s3_bucket = "${var.s3_bucket}"
  }
}

resource "aws_iam_role_policy" "k8s-nodes" {
  name   = "nodes.${var.cluster_name}"
  role   = "${aws_iam_role.k8s-nodes.name}"
  policy = "${data.template_file.aws_iam_role_policy_nodes_policy.rendered}"
}

data "aws_vpc" "k8s_vpc" {
  id = "${var.vpc_id}"
}

data "template_file" "k8s_master_user_data" {
  template = "${file("${path.module}/data/aws_launch_configuration_k8s_master.user_data")}"

  vars {
    cluster_name = "${var.cluster_name}"
    s3_bucket = "${var.s3_bucket}"
    region = "${var.region}"
    vpc_cidr_block = "${data.aws_vpc.k8s_vpc.cidr_block}"
    service_cluster_iprange = "172.31.0.0/19"
    kube_controller_cidr = "172.31.128.0/17"
    kube_proxy_cidr = "172.31.128.0/17"
    cluster_dns_ip = "172.31.0.10"
    instance_group_name = "master-us-west-1c"
  }
}

resource "aws_launch_configuration" "k8s-master" {
  name_prefix                 = "${var.cluster_name}-"
  image_id                    = "${var.ami_id}"
  instance_type               = "${var.master_instance_size}"
  key_name                    = "${var.key_pair}"
  iam_instance_profile        = "${aws_iam_instance_profile.k8s-master.id}"
  security_groups             = ["${aws_security_group.k8s-master.id}"]
  associate_public_ip_address = false
  #user_data                   = "${file("${path.module}/data/aws_launch_configuration_k8s_master.user_data")}"
  user_data                   = "${data.template_file.k8s_master_user_data.rendered}"

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

data "template_file" "k8s_nodes_user_data" {
  template = "${file("${path.module}/data/aws_launch_configuration_k8s_nodes.user_data")}"

  vars {
    cluster_name = "${var.cluster_name}"
    s3_bucket = "${var.s3_bucket}"
    region = "${var.region}"
    vpc_cidr_block = "${data.aws_vpc.k8s_vpc.cidr_block}"
    service_cluster_iprange = "172.31.0.0/19"
    kube_controller_cidr = "172.31.128.0/17"
    kube_proxy_cidr = "172.31.128.0/17"
    cluster_dns_ip = "172.31.0.10"
    instance_group_name = "master-us-west-1c"
  }
}

resource "aws_launch_configuration" "k8s-nodes" {
  name_prefix                 = "${var.cluster_name}-"
  image_id                    = "${var.ami_id}"
  instance_type               = "${var.node_instance_size}"
  key_name                    = "${var.key_pair}"
  iam_instance_profile        = "${aws_iam_instance_profile.k8s-nodes.id}"
  security_groups             = ["${aws_security_group.k8s-nodes.id}"]
  associate_public_ip_address = false
  user_data                   = "${data.template_file.k8s_nodes_user_data.rendered}"

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

resource "aws_route53_record" "api-k8s-endpoint" {
  name = "api.${var.cluster_name}"
  type = "A"

  alias = {
    name                   = "${aws_elb.api-elb-k8s.dns_name}"
    zone_id                = "${aws_elb.api-elb-k8s.zone_id}"
    evaluate_target_health = false
  }

  zone_id = "/hostedzone/${var.r53_zone_id}"
}

terraform = {
  required_version = ">= 0.9.3"
}
