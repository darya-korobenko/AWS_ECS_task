resource "aws_ecr_repository" "app_ecr_repo" {
  name = "app-repo"
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "app-cluster"
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "app-first-task"
  requires_compatibilities = ["FARGATE"] # use Fargate as the launch type
  network_mode             = "awsvpc"    # add VPN network mode as this is required for Fargate
  memory                   = 512         # specify the memory that container requires
  cpu                      = 256         # specify the CPU that container requires
  execution_role_arn       = "${aws_iam_role.ecsTaskExecutionRole.arn}" # grant required permissions to make AWS API calls
  container_definitions    = <<DEFINITION
  [
    {
      "name": "app-first-task",
      "image": "${aws_ecr_repository.app_ecr_repo.repository_url}",
      "essential": true,
      "memory": 512,
      "cpu": 256,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ]
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "app_service" {
  name            = "app-first-service" # name the service
  cluster         = "${aws_ecs_cluster.my_cluster.id}" # reference the created cluster
  task_definition = "${aws_ecs_task_definition.app_task.arn}" # reference the task that the service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # set up the number of containers to 3

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # reference the target group
    container_name   = "${aws_ecs_task_definition.app_task.family}"
    container_port   = 3000 # specify the container port
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}"]
    assign_public_ip = true # provide the containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"] # det up the security group
  }
}


resource "aws_ecs_service" "app_service" {
  name            = "app-first-service" # name the service
  cluster         = "${aws_ecs_cluster.my_cluster.id}" # reference the created cluster
  task_definition = "${aws_ecs_task_definition.app_task.arn}" # reference the task that the service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # set up the number of containers to 3

  load_balancer {
    target_group_arn = "${aws_lb_target_group.target_group.arn}" # reference the target group
    container_name   = "${aws_ecs_task_definition.app_task.family}"
    container_port   = 3000 # specify the container port
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}"]
    assign_public_ip = true # provide the containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"] # det up the security group
  }
}

resource "aws_security_group" "service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # allow traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress { # allow all egress rule
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
