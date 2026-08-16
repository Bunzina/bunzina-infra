resource "aws_ecr_repository" "bunzina" {
  name                 = var.project_name
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "bunzina_chart" {
  name                 = "app-chart"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_ecr_lifecycle_policy" "bunzina" {
  repository = aws_ecr_repository.bunzina.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Manter apenas as 10 imagens mais recentes"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }]
  })
}