#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment the following line to debug stub failures
export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

setup() {

  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_PATH="terraform"
  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_GROUP="Test"
  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_APPLY="true"
  export BUILDKITE_PLUGIN_SIMPLE_TERRAFORM_BLOCK="Confirm apply"

}

teardown() {
  echo "$output" >&3
}

@test "Generate pipeline" {

  stub buildkite-agent

  run "$PWD/hooks/command"

  assert_success

  assert_output --partial "init"
  assert_output --partial "plan"
  assert_output --partial "apply"
  

}


