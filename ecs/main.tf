# ==================== ecs_cluster ==========================
resource "aws_ecs_cluster" "default" {
  name = var.name
}

# ==================== aws_ecs_task_definition ==========================
data "aws_iam_policy" "ecs_task_role_policy" {
  arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

data "aws_iam_policy_document" "ecs_task_role" {
  source_json = data.aws_iam_policy.ecs_task_role_policy.policy
}

module "iam_role_ecs_task_role" {
    source        = "../iam_role"
    name          = "${var.name}-esc-task"
    identifier    = "ecs-tasks.amazonaws.com"
    policy_json   = data.aws_iam_policy_document.ecs_task_role.json
}

# ecs task iam role
resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.name}-esc-execution-task"
  assume_role_policy = file("${path.module}/assume_role_policy/ecs_task.json")
}

data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_execution" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "secretsmanager:GetSecretValue", "kms:Decrypt"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_task_execution" {
  policy = data.aws_iam_policy_document.ecs_task_execution.json
}

# タスクの実行ロール
resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution.arn
}

resource "aws_cloudwatch_log_group" "tasc-definition" {
  name              = "/ecs/${var.name}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "default" {
  family = var.name
  container_definitions    = var.container_definitions
  network_mode             = "awsvpc"
  memory                   = var.memory
  cpu                      = var.cpu
  requires_compatibilities = ["FARGATE"]
  task_role_arn            = module.iam_role_ecs_task_role.iam_role_arn
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  depends_on = [
    aws_cloudwatch_log_group.tasc-definition
  ]
}

# ==================== aws_ecs_service ==========================

resource "aws_security_group" "service-alb" {
  name   = "${var.name}-alb"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-alb"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb" "default" {
  name            = var.name
  security_groups = [aws_security_group.service-alb.id]
  subnets         = var.alb_subnet_ids
  internal        = false
  # 削除可否(とりあえずfalseにしている)
  enable_deletion_protection = false
}

resource "aws_alb_target_group" "default" {
  name = var.name
  # ECS向けのパケットには80番を通す
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    interval = 60
    path     = "/"
    // NOTE: defaultはtraffic-portなので指定しなくてOK
    //port                = 80  
    protocol            = "HTTP"
    timeout             = 20
    unhealthy_threshold = 4
    matcher             = 200
  }

  depends_on = [
    aws_alb.default
  ]
}

resource "aws_alb_listener" "port-80" {
  count = var.alb_certificate_arn == "" ? 1 : 0
  load_balancer_arn = aws_alb.default.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.default.arn
    type             = "forward"
  }
}

// HTTPSがあるばあいは、HTTPSにリダイレクトする。
resource "aws_alb_listener" "port-80-redirect" {
  count = var.alb_certificate_arn == "" ? 0 : 1
  load_balancer_arn = aws_alb.default.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

// 443ポートの設定。今回は事前にAWS Certificate Managerで作成済みの証明書を設定。
resource "aws_alb_listener" "port-443" {
  count = var.alb_certificate_arn == "" ? 0 : 1
  load_balancer_arn = aws_alb.default.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = var.alb_certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.default.arn
    type             = "forward"
  }
}

# NOTE: ECS Serviceに紐付けるためのロール
resource "aws_iam_role_policy_attachment" "ecs_service" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_security_group" "ecs_service" {
  name   = "${var.name}-ecs-service"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-ecs-service"
  }
}

resource "aws_ecs_service" "default" {
  name            = var.name
  cluster         = aws_ecs_cluster.default.id
  task_definition = aws_ecs_task_definition.default.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  load_balancer {
    target_group_arn = aws_alb_target_group.default.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  network_configuration {
    subnets = var.ecs_subnet_ids
    security_groups = [
      aws_security_group.ecs_service.id
    ]
    # public_subnetを割り当てるときはtrueにする 
    # assign_public_ip = true
  }

  # NOTE: albはprovisioningの時間があるため、depends_on定義しないと失敗する
  depends_on = [
    aws_alb_target_group.default,
    aws_ecs_cluster.default,
    aws_ecs_task_definition.default
  ]
}

################################# autoscaling #################################
resource "aws_iam_role" "ecs_autoscaling_role" {
  count              = var.has_autoScaling ? 1 : 0
  name               = "role-${var.name}-ecs-autoscaling"
  assume_role_policy = file("${path.module}/assume_role_policy/ecs_task.json")
}

resource "aws_iam_policy_attachment" "ecs_autoscale_role_attach" {
  count      = var.has_autoScaling ? 1 : 0
  name       = "role-attach-${var.name}-ecs-autoscaling"
  roles      = [aws_iam_role.ecs_autoscaling_role[count.index].name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}

locals {
  autoscaling_resource_id = "service/${aws_ecs_cluster.default.name}/${aws_ecs_service.default.name}"
}

resource "aws_appautoscaling_target" "default" {
  count              = var.has_autoScaling ? 1 : 0
  service_namespace  = "ecs"
  resource_id        = local.autoscaling_resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = aws_iam_role.ecs_autoscaling_role[count.index].arn
  min_capacity       = var.autoscaling_min_capacity
  max_capacity       = var.autoscaling_max_capacity
}

resource "aws_appautoscaling_policy" "scale_out" {
  count              = var.has_autoScaling ? 1 : 0
  name               = "scale-out"
  resource_id        = local.autoscaling_resource_id
  scalable_dimension = aws_appautoscaling_target.default[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.default[count.index].service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = 1
    }
  }
  depends_on = [aws_appautoscaling_target.default]
}

resource "aws_appautoscaling_policy" "scale_in" {
  count              = var.has_autoScaling ? 1 : 0
  name               = "scale-in"
  resource_id        = local.autoscaling_resource_id
  scalable_dimension = aws_appautoscaling_target.default[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.default[count.index].service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
  depends_on = [aws_appautoscaling_target.default]
}

# NOTE: 5分でCPU使用率が30%を上回ったら
## ECS AutoScaling Alarm
resource "aws_cloudwatch_metric_alarm" "high" {
  count              = var.has_autoScaling ? 1 : 0
  alarm_name          = "${var.name}-ECS-CPU-Utilization-High-30"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    ClusterName = aws_ecs_cluster.default.name
    ServiceName = aws_ecs_service.default.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_out[count.index].arn]
}

# NOTE: 5分でCPU使用率が5%を下回ったら
resource "aws_cloudwatch_metric_alarm" "low" {
  count              = var.has_autoScaling ? 1 : 0
  alarm_name          = "${var.name}-ECS-CPU-Utilization-Low-5"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "5"

  dimensions = {
    ClusterName = aws_ecs_cluster.default.name
    ServiceName = aws_ecs_service.default.name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_in[count.index].arn]
}
