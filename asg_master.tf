resource "aws_autoscaling_attachment" "k8s-master" {
  elb                    = "${aws_elb.api-elb-k8s.id}"
  autoscaling_group_name = "${aws_autoscaling_group.k8s-master.id}"
}

resource "aws_autoscaling_group" "k8s-master" {
  name                 = "k8s-master-${var.cluster_name}"
  launch_configuration = "${aws_launch_configuration.k8s-master.id}"
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["${var.subnet_id_2}"]

  tag = {
    key                 = "KubernetesCluster"
    value               = "${var.cluster_name}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "master-us-west-1c.masters.${var.cluster_name}"
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
