# Simple Terraform Buildkite Plugin

A Buildkite plugin for generating terraform workflow pipeline steps via terraform in docker container.

## Example
Add the following to your `pipeline.yml`:

```yml
steps:
  - label: "Terraform"
    plugins:
    - dizzzan/simple-terraform#v1.0.0:
        path: "my-terraform-directory"
        apply: true
        block: ":terraform: Confirm Apply"
        group: "Test Group"
```

This will yield a pipeline approximately like:

```yml
steps:
  - group: "Test Group"
    steps:

      - label: "Terraform init"
        command: "init -input=false"
        plugins:
        - docker:
            image: "hashicorp/terraform:latest"
            mount-checkout: false
            workdir: /work
            propagate-environment: true
            propagate-aws-auth-tokens: true
            volumes: 
              - my-terraform-directory:/work
      
      - wait

      - label: "Terraform validate"
        command: "validate"
        plugins:
        - docker:
            image: "hashicorp/terraform:latest"
            mount-checkout: false
            workdir: /work
            propagate-environment: true
            propagate-aws-auth-tokens: true
            volumes: 
              - my-terraform-directory:/work
      
      - wait 

      - label: "Terraform plan"
        command: "plan -out=tfplan.out -input=false && terraform show tfplan.out" 
        plugins:
        - docker:
            image: "hashicorp/terraform:latest"
            mount-checkout: false
            workdir: /work
            propagate-environment: true
            propagate-aws-auth-tokens: true
            volumes: 
              - my-terraform-directory:/work

      - block: ":terraform: Confirm Apply"

      - label: "Terraform apply"
        command: "apply -auto-approve -input=false" 
        plugins:
        - docker:
            image: "hashicorp/terraform:latest"
            mount-checkout: false
            workdir: /work
            propagate-environment: true
            propagate-aws-auth-tokens: true
            volumes: 
              - my-terraform-directory:/work
```      
... which will then be uploaded by the agent via `buildkite-agent pipeline upload` 


## Configuration

### `path` (required, string)
Relative path to the terraform configuration
- Use '.' for the build directory
- This directory is mounted as /workdir in the Terraform container

### `group` (optional, string)
If specified, add all steps to a group using of this name
> Default: null

### `validate` (optional, boolean)
Whether to run a `terraform validate` step
> Default: true

### `init` (optional, boolean)
Whether to run a `terraform init` step
> Default: true

### `plan` (optional, boolean)
Whether to run a `terraform plan` step
> Default: true

### `wait` (optional, boolean)
Whether to add `wait` between each (init, validate, plan, apply) step
> Default: true
 
### `block` (optional, string)
If set, add a `block` before `apply` or `destroy` steps using the specified message.
> Default: null

### `init-args` (optional, string)
Arguments to pass to `terraform init`
> Default: -input=false

### `validate-args` (optional, string)
Arguments to pass to `terraform validate`
> Default: null

### `plan-args` (optional, string)
Arguments to pass to `terraform plan`
> Default: -out=tfplan.out -input=false

### `apply-args` (optional, string)
Arguments to pass to `terraform apply`
> Default: -auto-approve -input=false tfplan.out

### `destroy-args` (string)
Arguments to pass to `terraform destroy`
> Default: -auto-approve -input=false tfplan.out

### `terraform-version` (optional, string)
Version tag of the terraform docker image to use
> Default: latest

### `docker-version` (optional, string)
Version of the Buildkite docker plugin to use. Leave null to use latest.
> Default: null

### `propagate-aws-auth-tokens` (optional, boolean)
Use the [`propagate-aws-auth-tokens` flag for the Docker plugin](https://github.com/buildkite-plugins/docker-buildkite-plugin#propagate-aws-auth-tokens-optional-boolean)
> Default: true

### `propagate-environment` (optional, boolean)
Use the [`propagate-environment` flag for the Docker plugin](https://github.com/buildkite-plugins/docker-buildkite-plugin#propagate-environment-optional-boolean)
> Default: true

### `debug` (optional, boolean)
Instead of uploading the pipeline, it will be printed out only. No steps will be run.
> Default: false