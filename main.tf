#locals {
#  inline_policy_count = length(var.policy_json) > 0 ? 1 : 0
#}



data "aws_iam_policy_document" "example" {
  statement {
    sid = "1"

    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

}

resource "aws_iam_policy" "example" {
  count  = length(data.aws_iam_policy_document.example.json) > 0 ? 1 : 0
  name   = "example_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.example.json
}
