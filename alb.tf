
#Application load balancer
resource "aws_alb" "alb" {
    name            = "alb-ltia"
    internal        = false
    subnets         = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]
    security_groups = [ aws_security_group.elb_sg.id ]
    
}

#ALB Target group creation
resource "aws_alb_target_group" "alb_targets"{
    name     = "apache-targets"
    vpc_id   = aws_vpc.vpc_ltia.id
    port     = 80
    protocol = "HTTP"

    health_check {
      path     = "/"
      port     = 80
      protocol = "HTTP"
    }
}

#Target instance registration to group
resource "aws_alb_target_group_attachment" "apache1_target_attachment" {
    target_group_arn = aws_alb_target_group.alb_targets.arn
    target_id        = aws_instance.apache1.id 
    port             = 80
}

resource "aws_alb_target_group_attachment" "apache2_target_attachment" {
    target_group_arn = aws_alb_target_group.alb_targets.arn
    target_id        = aws_instance.apache2.id 
    port             = 80


}

#Attach http listener for ALB 
resource "aws_alb_listener" "alb_listener"{
    load_balancer_arn = aws_alb.alb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
      target_group_arn = aws_alb_target_group.alb_targets.arn
      type             = "forward"
    }       
}