output "cluster_name" {
  value = "${var.cluster_name}"
}

output "master_autoscaling_group_ids" {
  value = ["${aws_autoscaling_group.k8s-master.id}"]
}

output "master_security_group_ids" {
  value = ["${aws_security_group.k8s-master.id}"]
}

output "masters_role_arn" {
  value = "${aws_iam_role.masters-iam-role.arn}"
}

output "masters_role_name" {
  value = "${aws_iam_role.masters-iam-role.name}"
}

output "node_autoscaling_group_ids" {
  value = ["${aws_autoscaling_group.k8s-nodes.id}"]
}

output "node_security_group_ids" {
  value = ["${aws_security_group.k8s-nodes.id}"]
}

# output "node_subnet_ids" {
#   value = ["${aws_subnet.us-west-1b-one-colabit-store.id}", "${aws_subnet.us-west-1c-one-colabit-store.id}"]
# }

output "nodes_role_arn" {
  value = "${aws_iam_role.k8s-nodes.arn}"
}

output "nodes_role_name" {
  value = "${aws_iam_role.k8s-nodes.name}"
}

output "region" {
  value = "${var.region}"
}

# output "route_table_private-us-west-1b_id" {
#   value = "${aws_route_table.private-us-west-1b-one-colabit-store.id}"
# }

# output "route_table_private-us-west-1c_id" {
#   value = "${aws_route_table.private-us-west-1c-one-colabit-store.id}"
# }

# output "route_table_public_id" {
#   value = "${aws_route_table.one-colabit-store.id}"
# }

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
