resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    =  [aws_security_group.sg4.id]
  subnets = [aws_subnet.db[0].id,aws_subnet.db[1].id]
  enable_deletion_protection = false

 

  tags = {
    Environment = "production"
  }

}