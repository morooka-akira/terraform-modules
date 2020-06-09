
module "iam_role" {
  source        = "./iam_role"
  name          = var.name
  identifier    = var.identifier
  policy        = var.policy_json
}