#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# Short-circuit if init.sh has already been sourced
[[ $(type -t kounner::init::loaded) == function ]] && return 0

# The root of the build/dist directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"

# Marker function to indicate init.sh has been fully sourced
kounner::init::loaded() {
  return 0
}