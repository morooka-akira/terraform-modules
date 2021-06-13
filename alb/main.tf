resource "aws_security_group" "default" {
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
  security_groups = [aws_security_group.default.id]
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
  target_type = var.target_type

  health_check {
    interval = 60
    path     = var.health_check_path
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