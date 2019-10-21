resource "aws_route53_record" "sftp_route53" {
  count   = var.dns["use_route53"] ? 1 : 0
  zone_id = data.aws_route53_zone.main[count.index].zone_id
  name    = var.dns["hostname"]
  type    = "CNAME"
  ttl     = 300

  records = [
    aws_transfer_server.sftp.endpoint,
  ]
}

resource "aws_iam_role" "sftp_role" {
  name = "${var.sftp["name"]}-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "sftp_policy" {
  name = "${var.sftp["name"]}-policy"
  role = aws_iam_role.sftp_role.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Sid": "AllowFullAccesstoCloudWatchLogs",
        "Effect": "Allow",
        "Action": [
            "logs:*"
        ],
        "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_transfer_server" "sftp" {
  identity_provider_type = "SERVICE_MANAGED"
  logging_role           = aws_iam_role.sftp_role.arn

  tags = merge(
    {
      Name = var.sftp["name"]
    },
    var.custom_tags
  )
}

output "sftp_server_endpoint" {
  value = aws_transfer_server.sftp.endpoint
}

output "sftp_server_id" {
  value = aws_transfer_server.sftp.id
}
