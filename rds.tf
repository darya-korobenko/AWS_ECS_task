resource "aws_db_instance" "rds" {
  allocated_storage     = 20
  storage_type          = "gp2"
  engine                = "sqlserver-ex"
  engine_version        = "14.00.3420.3.v1"
  instance_class        = "db.t2.micro"
  username              = "admin" 
  password              = "YourPassword" # to encrypt
  parameter_group_name  = "default.sqlserver-ex-14.00"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds.id]
}

resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Security group for RDS"
  
  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    # allow traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}
