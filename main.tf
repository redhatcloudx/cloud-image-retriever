# Configures the IAM OpenID Connect provider for GitHub Actions
# https://benoitboure.com/securely-access-your-aws-resources-from-github-actions

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "cloudx"
  default_tags {
    tags = {
      Project = "cloud-image-retriever"
    }
  }
}

resource "aws_iam_openid_connect_provider" "github_actions_image_retriever" {
  url = "https://token.actions.githubusercontent.com"

  # Also known in AWS interfaces as "Audience"
  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    Name        = "github-actions"
    Description = "Allows GitHub Actions to assume roles in this account"
  }
}

data "aws_iam_policy_document" "github_actions_web_identity_policy" {
  statement {
    sid     = "GitHubActionsWebIdentityPolicy"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions_image_retriever.arn]
    }

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:redhatcloudx/cloud-image-retriever:*"]
    }
  }
}

data "aws_iam_policy_document" "get_image_data" {
  statement {
    sid    = "GetImageData"
    effect = "Allow"

    actions = [
      "ec2:DescribeImages",
      "ec2:DescribeRegions"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "get_image_data" {
  name = "get_image_data"

  policy = data.aws_iam_policy_document.get_image_data.json
}

resource "aws_iam_role" "github_actions_image_retriever" {
  name = "github_actions_image_retriever"

  managed_policy_arns = [aws_iam_policy.get_image_data.arn]
  assume_role_policy  = data.aws_iam_policy_document.github_actions_web_identity_policy.json
}