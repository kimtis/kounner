#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

function kounner::util::download_file() {
  local -r url=$1
  local -r destination_file=$2
  rm "${destination_file}" 2&> /dev/null || true
  curl -fsSL --retry 3 "${url}" -o "${destination_file}"
}

function kounner::util::host_os() {
  case "$(uname -s)" in
    Darwin) echo "darwin" ;;
    Linux) echo "linux" ;;
    *) echo "Unsupported host OS" >&2; exit 1 ;;
  esac
}

function kounner::util::host_arch() {
  case "$(uname -m)" in
    x86_64*|amd64*) echo "amd64" ;;
    aarch64*|arm64*) echo "arm64" ;;
    *) echo "Unsupported host arch" >&2; exit 1 ;;
  esac
}
