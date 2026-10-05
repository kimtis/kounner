#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

function kounner::log::info() {
  for message; do
    echo "${message}"
  done
}

function kounner::log::error() {
  echo "!!! ${1-}" >&2
}

function kounner::log::status() {
  timestamp=$(date +"[%m%d %H:%M:%S]")
  echo "+++ ${timestamp} ${1}"
  shift
  for message; do
    echo "    ${message}"
  done
}
