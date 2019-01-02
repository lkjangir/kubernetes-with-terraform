resource "aws_autoscaling_group" "k8s-nodes" {
  name                 = "nodes.${var.cluster_name}"
  launch_configuration = "${aws_launch_configuration.k8s-nodes.id}"
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = ["${var.subnet_id_1}", "${var.subnet_id_2}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "${var.cluster_name}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "nodes.${var.cluster_name}"
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