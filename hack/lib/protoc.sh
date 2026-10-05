#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"
source "${PROJECT_ROOT}/hack/lib/init.sh"
source "${PROJECT_ROOT}/hack/lib/logging.sh"
source "${PROJECT_ROOT}/hack/lib/util.sh"

PROTOC_VERSION=23.4

# Checks that the current protoc version matches the required version and installs if not
function kounner::protoc::check_protoc() {
  local third_party_dir="${PROJECT_ROOT}/third_party/protoc"
  if [[ -x "${third_party_dir}/bin/protoc" ]]; then
    PATH="${third_party_dir}/bin:${PATH}"
    export PATH
  fi

  if ! command -v protoc &> /dev/null || [[ "$(protoc --version)" != "libprotoc ${PROTOC_VERSION}"* ]]; then
    kounner::log::status "Generating protobuf requires protoc ${PROTOC_VERSION}. Installing..."
    kounner::protoc::install
  else
    kounner::log::status "Found protoc $(protoc --version)"
  fi
}

# Generates Go code from Protocol Buffer definitions
function kounner::protoc::generate_go() {
  kounner::log::status "Ensuring protoc v${PROTOC_VERSION} is available..."
  kounner::protoc::check_protoc

  kounner::log::status "Installing Go protoc plugins..."
  export PATH="$(go env GOPATH)/bin:${PATH}"
  go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

  kounner::log::status "Generating Protocol Buffers Go code..."
  
  local proto_files
  proto_files=$(find "${PROJECT_ROOT}/api" -name "*.proto")

  for proto in ${proto_files}; do
    kounner::log::info "Processing ${proto}"
  done

  protoc \
    --proto_path="${PROJECT_ROOT}" \
    --go_out="${PROJECT_ROOT}" \
    --go_opt=paths=source_relative \
    --go-grpc_out="${PROJECT_ROOT}" \
    --go-grpc_opt=paths=source_relative \
    ${proto_files}

  kounner::log::status "Protocol Buffers code generation completed successfully."
}
function kounner::protoc::install() {
  local os
  local arch
  local download_folder
  local download_file
  local third_party_dir

  os=$(kounner::util::host_os)
  arch=$(kounner::util::host_arch)
  download_folder="protoc-v${PROTOC_VERSION}-${os}-${arch}"
  download_file="${download_folder}.zip"
  third_party_dir="${PROJECT_ROOT}/third_party"
  
  mkdir -p "${third_party_dir}"
  (
    cd "${third_party_dir}" || return 1
    if [[ ! -d "${download_folder}" ]]; then
      local url
      if [[ ${os} == "darwin" ]]; then
        url="https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-osx-x86_64.zip"
      elif [[ ${os} == "linux" && ${arch} == "amd64" ]]; then
        url="https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip"
      elif [[ ${os} == "linux" && ${arch} == "arm64" ]]; then
        url="https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-aarch_64.zip"
      else
        kounner::log::error "This install script does not support ${os}/${arch}"
        return 1
      fi
      kounner::util::download_file "${url}" "${download_file}"
      python3 -c "import zipfile; zipfile.ZipFile('${download_file}').extractall('${download_folder}')"
      mv "${download_folder}" protoc_tmp
      mkdir -p "${download_folder}/bin"
      mv protoc_tmp/bin/protoc "${download_folder}/bin/protoc"
      rm -rf protoc_tmp "${download_file}"
    fi
    kounner::log::status "protoc v${PROTOC_VERSION} installed successfully."
  )
  PATH="${third_party_dir}/${download_folder}/bin:${PATH}"
  export PATH
}
