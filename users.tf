resource "aws_iam_role" "sftp_user_role" {
  count = length(var.sftp_users)
  name  = "${var.sftp["name"]}-${var.sftp_users[count.index]["name"]}"

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

resource "aws_iam_role_policy" "sftp_user_policy" {
  count = length(var.sftp_users)
  name  = "${var.sftp["name"]}-${var.sftp_users[count.index]["name"]}"

  role = aws_iam_role.sftp_user_role[count.index].id

  policy = var.sftp_users[count.index]["policy"]
}

resource "aws_transfer_user" "sftp_user" {
  count          = length(var.sftp_users)
  server_id      = aws_transfer_server.sftp.id
  user_name      = var.sftp_users[count.index]["name"]
  home_directory = var.sftp_users[count.index]["home_directory"]
  role           = aws_iam_role.sftp_user_role[count.index].arn
  tags           = var.custom_tags
}

resource "aws_transfer_ssh_key" "sftp_user_key" {
  count     = length(var.sftp_users)
  server_id = aws_transfer_server.sftp.id
  user_name = aws_transfer_user.sftp_user[count.index].user_name
  body      = var.sftp_users[count.index]["ssh_key"]
}
