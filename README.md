# cross-cutting-aws-bootstrap

A repo used for boostrapping SPP Cross Cutting AWS accounts.

It will setup the following:

- S3 Buckets for terraform state
- DynamoDB tables for terraform locks
- Create an IAM user and role for use with concourse
- Export `access_key_id`, `secret_access_key` and `deploy_role` for the concourse IAM user.

## Pre-reqs

- [Terragrunt](https://terragrunt.gruntwork.io/)

    ```sh
    brew install terragrunt
    ```

- [yq](https://github.com/mikefarah/yq)

    ```sh
    brew install yq
    ```

- [gcloud](https://formulae.brew.sh/cask/google-cloud-sdk)

    ```sh
    brew install --cask google-cloud-sdk
    echo 'export CLOUDSDK_PYTHON="$(brew --prefix)/opt/python@3.8/libexec/bin/python"' >> ~/.profile
    echo 'source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc"' >> ~/.profile
    echo 'source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc"' >> ~/.profile
    ```

- [fly](https://concourse.gcp.onsdigital.uk/api/v1/cli?arch=amd64&platform=darwin)

## Bootstrapping a new account

Current environments:

- sandbox

From root directory:

```sh
TF_ENV=<env_name> ./ips_user_setup/scripts/setup.sh
```

### Setting the concourse user credentials in concourse

In order to deploy our terraform code via concourse we need to authenticate and assume a role using credentials stored
as secrets in our concourse environments.

To keep this as simple as possible a script has been provided.

**NOTE**: Make sure your secret name is scoped to your environment.

```sh
TF_ENV=<env_name> SECRET_NAME=<secret_name> ./scripts/set_aws_creds.sh
```

For example:

```sh
TF_ENV=integration SECRET_NAME=awsint ./scripts/set_aws_creds.sh
```

This makes our credentials usable via `((awsint.access_key_id))`, `((awsint.secret_access_key))` and
`((awsint.deploy_role))` in our concourse pipelines.

#### You can check these secrets have set properly

```sh
SECRET_NAME=<secret_name> SECRET_KEY=<secret_key> ./scripts/check_secret.sh
```

For example:

```sh
SECRET_NAME=awssandbox SECRET_KEY=access_key_id ./scripts/check_secret.sh
```
