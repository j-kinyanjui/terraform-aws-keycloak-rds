// Allow EC2 instance to register as ECS cluster member, fetch ECR images, write logs to CloudWatch
data "aws_iam_policy_document" "ec2_instance_assume_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "app" {
  name = "ecs_app_instance_profile"
  role = aws_iam_role.ec2_instance_role.name
}

resource "aws_iam_role" "ec2_instance_role" {
  assume_role_policy = data.aws_iam_policy_document.ec2_instance_assume_role_policy.json
  name = "EcsClusterEc2InstanceRole"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role" {
  role = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

// Allow ECS service to interact with LoadBalancers
data "aws_iam_policy_document" "ecs_service_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_service_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_service_role_policy.json
  name = "EcsClusterServiceRole"
}

resource "aws_iam_role_policy_attachment" "service_role" {
  role = aws_iam_role.ecs_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

data "aws_iam_policy_document" "ecs_task_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_policy.json
  name = "EcsClusterTaskRole"
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
  role = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "allow_create_log_groups" {
  statement {
    actions = [
      "logs:CreateLogGroup"]
    resources = [
      "*"]
  }
}

resource "aws_iam_role_policy" "allow_create_log_groups" {
  policy = data.aws_iam_policy_document.allow_create_log_groups.json
  role = aws_iam_role.ecs_task_role.id
}