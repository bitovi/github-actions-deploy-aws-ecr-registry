#!/bin/bash

set -e

# TODO: use templating
#    provide '.tf.tmpl' files in the 'operations/deployment' repo
#    and iterate over all of them to provide context with something like jinja
#    Example: https://github.com/mattrobenolt/jinja2-cli
#    jinja2 some_file.tmpl data.json --format=json

echo "In generate_provider.sh"

function generate_tf_state_file_name () {
  if [ -n "$TF_STATE_FILE_NAME" ]; then
    filename="$TF_STATE_FILE_NAME"
  else
    filename="tf-state-$1"
  fi

  if [ -n "$TF_STATE_FILE_NAME_APPEND" ]; then
    filename="${filename}-${TF_STATE_FILE_NAME_APPEND}"
  fi
  echo $filename
}

echo "
terraform {
  required_providers {
    aws = {
      source  = \"hashicorp/aws\"
      version = \"~> 5.0\"
    }
    random = {
      source  = \"hashicorp/random\"
      version = \">= 2.2\"
    }
  }

  backend \"s3\" {
    region  = \"${AWS_DEFAULT_REGION}\"
    bucket  = \"${TF_STATE_BUCKET}\"
    key     = \"$(generate_tf_state_file_name ecr)\"
    encrypt = true #AES-256encryption
  }
}

provider \"aws\" {
  region = \"${AWS_DEFAULT_REGION}\"
  alias = \"ecr\" 
  default_tags {
    tags = merge(
      local.ecr_tags
    )
  }
}
" > "${GITHUB_ACTION_PATH}/terraform_code/provider.tf"