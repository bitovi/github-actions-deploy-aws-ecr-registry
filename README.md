# Deploy an AWS hosted ECR Registry 

`bitovi/github-actions-deploy-aws-ecr-registry` deploys an AWS hosted ECR Registry.

This action uses our new GitHub Actions Commons repository, a library that contains multiple Terraform modules, allowing us to condense all of our tools in one repo, hence continuous improvements are made to it. 

## Action Summary
This action deploys an ECR Registry to store Docker and Open Container Initiative (OCI) images and artifacts.

If you would like to deploy a backend app/service, check out our other actions:
| Action | Purpose |
| ------ | ------- |
| [Deploy Docker to EC2](https://github.com/marketplace/actions/deploy-docker-to-aws-ec2) | Deploys a repo with a Dockerized application to a virtual machine (EC2) on AWS |
| [Deploy React to GitHub Pages](https://github.com/marketplace/actions/deploy-react-to-github-pages) | Builds and deploys a React application to GitHub Pages. |
| [Deploy static site to AWS (S3/CDN/R53)](https://github.com/marketplace/actions/deploy-static-site-to-aws-s3-cdn-r53) | Hosts a static site in AWS S3 with CloudFront |
<br/>

**And more!**, check our [list of actions in the GitHub marketplace](https://github.com/marketplace?category=&type=actions&verification=&query=bitovi)

# Need help or have questions?
This project is supported by [Bitovi, A DevOps consultancy](https://www.bitovi.com/services/devops-consulting).

You can **get help or ask questions** on our:

- [Discord Community](https://discord.gg/J7ejFsZnJ4Z)


Or, you can hire us for training, consulting, or development. [Set up a free consultation](https://www.bitovi.com/services/devops-consulting).

# Basic Use
For basic usage, create `.github/workflows/deploy.yaml` with the following to build on push.

```yaml
on:
  push:
    branches:
      - "main" # change to the branch you wish to deploy from

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - id: ecr-deploy
      uses: bitovi/github-actions-deploy-aws-ecr-registry@v0.1.0
      with:
        aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws_default_region: us-east-1

        aws_ecr_repo_create: true
```

### Inputs
1. [AWS Specific](#aws-specific)
1. [Action default inputs](#action-default-inputs)
1. [ECR Inputs](#ecr-inputs)

The following inputs can be used as `step.with` keys
<br/>
<br/>

#### **AWS Specific**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws_access_key_id` | String | AWS access key ID |
| `aws_secret_access_key` | String | AWS secret access key |
| `aws_session_token` | String | AWS session token |
| `aws_default_region` | String | AWS default region. Defaults to `us-east-1` |
| `aws_resource_identifier` | String | Set to override the AWS resource identifier for the deployment. Defaults to `${GITHUB_ORG_NAME}-${GITHUB_REPO_NAME}-${GITHUB_BRANCH_NAME}`. Use with destroy to destroy specific resources. |
| `aws_additional_tags` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to all provisioned resources.|
<br/>

#### **Action default inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `tf_stack_destroy` | Boolean  | Set to `true` to destroy the stack. |
| `tf_state_file_name` | String | Change this to be anything you want to. Carefull to be consistent here. A missing file could trigger recreation, or stepping over destruction of non-defined objects. Defaults to `tf-state-aws`. |
| `tf_state_file_name_append` | String | Appends a string to the tf-state-file. Setting this to `unique` will generate `tf-state-aws-unique`. (Can co-exist with `tf_state_file_name`) |
| `tf_state_bucket` | String | AWS S3 bucket name to use for Terraform state. See [note](#s3-buckets-naming) | 
| `tf_state_bucket_destroy` | Boolean | Force purge and deletion of S3 bucket defined. Any file contained there will be destroyed. `tf_stack_destroy` must also be `true`. Default is `false`. |
| `bitops_code_only` | Boolean | If `true`, will run only the generation phase of BitOps, where the Terraform and Ansible code is built. |
| `bitops_code_store` | Boolean | Store BitOps generated code as a GitHub artifact. |
<br/>

#### **ECR Inputs**
| Name             | Type    | Description                        |
|------------------|---------|------------------------------------|
| `aws_ecr_repo_create` | Boolean | Determines whether a repository will be created.' |
| `aws_ecr_repo_type` | String | The type of repository to create. Either `public` or `private`. Defaults to `private`.' |
| `aws_ecr_repo_name` | String | The name of the repository. If none, will use the default resource-identifier.' |
| `aws_ecr_repo_mutable` | Boolean | The tag mutability setting for the repository. Set this to true if `MUTABLE`. Defaults to false, so `IMMUTABLE`' |
| `aws_ecr_repo_encryption_type` | String | The encryption type for the repository. Must be one of: `KMS` or `AES256`. Defaults to `AES256`' |
| `aws_ecr_repo_encryption_key_arn` | String | The ARN of the KMS key to use when encryption_type is `KMS`. If not specified, uses the default AWS managed key for ECR. |
| `aws_ecr_repo_force_destroy` | Boolean | If `true`, will delete the repository even if it contains images. Defaults to `false`' |
| `aws_ecr_repo_image_scan` | Boolean | Indicates whether images are scanned after being pushed to the repository (`true`) (default) or not scanned (`false`)' |
| `aws_ecr_registry_scan_rule` | String | One or multiple blocks specifying scanning rules to determine which repository filters are used and at what frequency. Defaults to `[]`.  |
| `aws_ecr_registry_pull_through_cache_rules` | String | List of pull through cache rules to create. Use map(map(string)). ' |
| `aws_ecr_registry_scan_config` | String | Scanning type to set for the registry. Can be either `ENHANCED` or `BASIC`. Defaults to null.' |
| `aws_ecr_registry_replication_rules_input` | String | The replication rules for a replication configuration. A maximum of 10 are allowed. Defaults to `[]`.' |
| `aws_ecr_repo_policy_attach` | Boolean | Determines whether a repository policy will be attached to the repository. Defaults to `true`.' |
| `aws_ecr_repo_policy_create` | Boolean | Determines whether a repository policy will be created. Defaults to `true`.' |
| `aws_ecr_repo_policy_input` | String | The JSON policy to apply to the repository. If defined overrides the default policy' |
| `aws_ecr_repo_read_arn` | String | The ARNs of the IAM users/roles that have read access to the repository. (Comma separated list)' |
| `aws_ecr_repo_write_arn` | String | The ARNs of the IAM users/roles that have read/write access to the repository. (Comma separated list)' |
| `aws_ecr_repo_read_arn_lambda` | String | The ARNs of the Lambda service roles that have read access to the repository. (Comma separated list)' |
| `aws_ecr_lifecycle_policy_input` | String | The policy document. This is a JSON formatted string. See more details about [Policy Parameters](http://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html#lifecycle_policy_parameters) in the official AWS docs' |
| `aws_ecr_public_repo_catalog` | String | Catalog data configuration for the repository. Defaults to `{}`.' |
| `aws_ecr_registry_policy_input` | String | The policy document. This is a JSON formatted string' |
| `aws_ecr_additional_tags ` | JSON | Add additional tags to the terraform [default tags](https://www.hashicorp.com/blog/default-tags-in-the-terraform-aws-provider), any tags put here will be added to ECR provisioned resources.|
<br/>

## Contributing
We would love for you to contribute to [`bitovi/github-actions-deploy-aws-ecr-registry`](hhttps://github.com/bitovi/github-actions-deploy-aws-ecr-registry).   [Issues](https://github.com/bitovi/github-actions-deploy-aws-ecr-registry/issues) and [Pull Requests](https://github.com/bitovi/github-actions-deploy-aws-ecr-registry/pulls) are welcome!

## License
The scripts and documentation in this project are released under the [MIT License](https://github.com/bitovi/github-actions-deploy-aws-ecr-registry/blob/main/LICENSE).

# Provided by Bitovi
[Bitovi](https://www.bitovi.com/) is a proud supporter of Open Source software.

# We want to hear from you.
Come chat with us about open source in our Bitovi community [Discord](https://discord.gg/J7ejFsZnJ4Z)!