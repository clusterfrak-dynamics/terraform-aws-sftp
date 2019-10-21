include {
  path = "${find_in_parent_folders()}"
}

terraform {
  source = "github.com/clusterfrak-dynamics/terraform-aws-sftp.git?ref=v1.0.0"
}

locals {
  aws_region   = basename(dirname(get_terragrunt_dir()))
  env         = "production"
  custom_tags = yamldecode(file("${get_terragrunt_dir()}/${find_in_parent_folders("common_tags.yaml")}"))
}

inputs = {

  env = local.env

  aws = {
    "region" = local.aws_region
  }

  dns = {
    use_route53 = false
    domain_name = "${local.env}.domain.name"
    hostname    = "sftp.${local.env}.domain.name"
  }

  custom_tags = merge(
    {
      Env = local.env
    },
    local.custom_tags
  )

  sftp = {
    name = "tf-${local.env}-sftp"
  }

  sftp_users = [
    {
      name = "USER"
      ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAkjfkdjdilkslkfhkV92+vYjwxp2VfpaoW2D0u353jSyYgD+LA6tuxLYNIltXSvOORZT/zU32Do310r2S7i0lMM1xWzXpbLihDYRJho47UboejzdGcai3tM5cu/fpqIRnFMqjNX8qlhQ83tds6XdbzAoY56K/2J+gDymIWKu9oJZM/Zts7LjBGb5+VXm4Cgh/emkevXyMzzbiR14/IShx4jKXf4yrUBLOFTrILob0c5qYREWGs1ANb43HbiAiwo0lO/if0l1BCu0sRt+k6s1jq1OXTOwTXGXxho8x+q4Z9n+ExqjWowebI8dvcIuhIMoj+Dn0+C79xhAHAs/WKMIQZNFZJQclbUyhQ=="
      policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowFullAccesstoS3",
            "Effect": "Allow",
            "Action": [
                "s3:*"
            ],
            "Resource": [
              "arn:aws:s3:::${local.env}-bucket",
              "arn:aws:s3:::${local.env}-bucket/*"
            ]
        }
    ]
}
POLICY
    }
  ]
}
