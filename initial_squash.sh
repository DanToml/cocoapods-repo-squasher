#!/usr/bin/env bash

set -e
set -o pipefail
set -x

USE_CIRCLECI_SPECS_MIRROR=1

clone_repo() {
  if [[ $USE_CIRCLECI_SPECS_MIRROR ]]; then
    echo "> Downloading Repo Script from S3"
    aws s3 --no-sign-request cp "s3://cocoapods-specs/latest.tar.gz" "latest.tar.gz"
    tar -C Specs -xzf latest.tar.gz
  else
    echo "> Cloning CocoaPods/Specs"
    git clone https://github.com/CocoaPods/Specs.git
  fi
}

measure_repo() {
  echo "> Measuring Specs Repo Size"
  du -sh Specs/
  du -sh Specs/.git
}

clone_repo
measure_repo
