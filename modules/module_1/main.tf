# ~ module avalanche_postgres_source
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

module "my_module_2" {
  source = "../module_2"

  policy_json = data.aws_iam_policy_document.example.json
}

