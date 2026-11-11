resource "aws_ecr_repository" "ecr" {
  count = length(var.ecr_name)
  name                 = var.ecr_name[count.index]
  image_scanning_configuration {
    scan_on_push = true
  }
}