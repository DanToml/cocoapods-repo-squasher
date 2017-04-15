#!/usr/bin/env bash

set -e
set -o pipefail
set -x

USE_CIRCLECI_SPECS_MIRROR=1

clone_repo() {
  if [[ $USE_CIRCLECI_SPECS_MIRROR ]]; then
    echo "> Downloading Repo Script from S3"
    aws s3 --no-sign-request cp "s3://cocoapods-specs/latest.tar.gz" "latest.tar.gz"
    tar -xzf latest.tar.gz
    mv master Specs
  else
    echo "> Cloning CocoaPods/Specs"
    git clone https://github.com/CocoaPods/Specs.git Specs
  fi
}

measure_repo() {
  echo "> Measuring Specs Repo Size"
  du -sh Specs/
  du -sh Specs/.git
}

squash_branch() {
  BRANCH_NAME=$1
  git checkout --orphan "new_$BRANCH_NAME"
  git add .
  git commit -m "Squashed!"
  git branch -D "$BRANCH_NAME"
  git checkout -b "$BRANCH_NAME"
  git branch -D "new_$BRANCH_NAME"
  git checkout master
}

tag_sharding_branch() {
  git checkout "predates_sharding_branch"
  git tag -d "v0.32.1"
  git tag "v0.32.1"
  git checkout master 
}

clone_repo
measure_repo
squash_branch "master"
squash_branch "predates_sharding_branch"
tag_sharding_branch
measure_repo
