# ~ modules/helm_app/iam.tf

variable "policy_arns" {
  type    = list(string) 
  default = []
}
variable "vault_token_policies" {
  type    = list(string) 
  default = []
}
variable "policy_json" {
  type    = string
  default = ""
}
variable "secrets" {
  type = map(object({
    access = map(list(string))
    keys   = list(string)
  }))
  default     = {}
}
locals {
  service_account_iam_policies = compact([
    var.policy_json,
    length(aws_secretsmanager_secret.secret) >= 1 ? data.aws_iam_policy_document.role_secrets_access.json : "",
  ])
}
data "aws_iam_policy_document" "policy" {
  source_policy_documents = local.service_account_iam_policies
}
data "aws_iam_policy_document" "role_secrets_access" {
  dynamic "statement" {
    for_each = var.secrets

    content {
      actions = flatten([
        ["secretsmanager:DescribeSecret"],
        contains(lookup(statement.value["access"], "self", []), "read") ? ["secretsmanager:GetSecretValue"] : [],
        contains(lookup(statement.value["access"], "self", []), "write") ? ["secretsmanager:PutSecretValue"] : [],
      ])
      resources = ["arn:aws:secretsmanager::${data.aws_caller_identity.current.account_id}:secret:${statement.key}"]
    }
  }
}
resource "aws_secretsmanager_secret" "secret" {
  # checkov:skip=CKV_AWS_149: We need to decide on a KMS CMK strategy. https://devotedhealth.atlassian.net/browse/TECH-3256
  for_each = toset(keys(var.secrets))
  name     = each.value

  lifecycle {
    ignore_changes = [description]
  }
}
module "my_module_3" {
  count = (
    var.policy_json != "" ||
    length(var.policy_arns) >= 1 ||
    length(var.secrets) >= 1 ||
    length(var.vault_token_policies) >= 1
  ) ? 1 : 0

  source     = "../module_3"
  policy_json = length(local.service_account_iam_policies) >= 1 ? data.aws_iam_policy_document.policy.json : ""
}
