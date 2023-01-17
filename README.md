# buildkite-plugin-foreach

A plugin for reducing duplication in buildkite pipelines.
After producing the pipeline, a `buildkite-agent pipeline upload` will be performed to ship the generated pipeline.

## Example
Add the following to your `pipeline.yml`:

```yml
steps:
  - label: "Terraform"
    plugins:
    - dizzzan/simple-terraform#v1.0.0:
        path: "my_terraform_directory"
        apply: true
        block: ":terraform: Confirm Apply"
        group: "Test Group"
```

This will yield a set of steps approximately like:
```yml

steps:
  - group: "Test Group"
    steps:

      - label: "Terraform init"
        command: "validate -input=false" # override args with plan_args
        plugins:
        - docker
            image: "hashicorp/terraform:latest"
            volumes: 
              - my_terraform_directory:/workdir
      
      - wait

      - label: "Terraform apply"
        command: "apply -auto-approve -input=false" 

      - label: "Terraform plan"
        command: "plan -out=tfout.plan -input=false" 
        plugins:
        - docker
            image: "hashicorp/terraform:latest" # use terraform_version if required, otherwise latest tag is used.
            volumes: 
              - my_terraform_directory:/workdir

      - label: "Terraform plan"
        command: "plan -out=tfout.plan -input=false" # override args with plan_args
        plugins:
        - docker # use docker_version if needed, otherwise latest plugin is used.
            image: "hashicorp/terraform:latest" # use terraform_version if required, otherwise latest tag is used.
            volumes: 
              - my_terraform_directory:/workdir
      

## Configuration

### `path` (optional, Required, string)
Relative path to the terraform configuration
- Use '.' for the build directory
- This directory is mounted as /workdir in the Terraform container

### `group` (optional, string)
If specified, add all steps to a group using of this name
> Default: null

### `validate` (optional, boolean)
Whether to run a `terraform validate` step
> Default: true

### `init` (optional, boolean, default=true)
Whether to run a `terraform init` step

### `plan` (optional, boolean, default=true)
Whether to run a `terraform plan` step

### `wait` (optional, boolean, default=true)
Whether to add `wait` between each (init, validate, plan, apply) step

### `block` (optional, string, default=null)
If set, add a `block` before `apply` or `destroy` steps using the specified message.

### `init_args` (optional, string, default: "-input=false")
Arguments to pass to `terraform init`

### validate_args (string, default: null)
Arguments to pass to `terraform validate`

### plan_args (string, default="-out=tfplan.out -input=false")
Arguments to pass to `terraform plan`

### apply_args (string, default: "-auto-approve -input=false tfplan.out")
Arguments to pass to `terraform apply`

### destroy_args(string, default="-auto-approve -input=false tfplan.out")
Arguments to pass to `terraform destroy`

### `terraform_version` (optional, string, default: "latest")
Version tag of the terraform docker image to use

### `docker_version` (optional, string, default:null)
Version of the Buildkite docker plugin to use. Leave null to use latest.

### `propagate_aws_auth_tokens` (optional, boolean, default:true)
Use the [`propagate_aws_auth_tokens` flag for the Docker plugin](https://github.com/buildkite-plugins/docker-buildkite-plugin#propagate-aws-auth-tokens-optional-boolean)

### `propagate_environment` (optional, boolean, default:true)
Use the [`propagate_environment` flag for the Docker plugin](https://github.com/buildkite-plugins/docker-buildkite-plugin#propagate-environment-optional-boolean)

