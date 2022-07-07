# ~ module irsa
variable "policy_json" {
  type    = string
  default = ""
}

locals {
  inline_policy_count = length(var.policy_json) > 0 ? 1 : 0
}

resource "aws_iam_policy" "example" {
  count  = local.inline_policy_count
  name   = "example_policy"
  policy = var.policy_json
}

