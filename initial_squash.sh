#!/usr/bin/env bash

set -e
set -o pipefail
set -x

clone_repo() {
  echo "> Fetching CocoaPods/Specs"
  curl -o latest.tar.gz https://cocoapods-specs.circleci.com/latest.tar.gz
  tar -xzf latest.tar.gz
  mv master Specs
  # git clone https://github.com/CocoaPods/Specs.git Specs
}

measure_repo() {
  echo "> Measuring Specs Repo Size"
  du -sh Specs/
  du -sh Specs/.git
}

git_exec() {
  git -C Specs $@
}

squash_branch() {
  BRANCH_NAME=$1
  git_exec checkout "$BRANCH_NAME"
  git_exec checkout --orphan "new_$BRANCH_NAME"
  git_exec add .
  git_exec commit -m "Squashed"
  git_exec branch -D "$BRANCH_NAME"
  git_exec checkout -b "$BRANCH_NAME"
  git_exec branch -D "new_$BRANCH_NAME"
  git_exec checkout master
}

tag_sharding_branch() {
  git_exec checkout "predates_sharding_branch"
  git_exec tag -d "v0.32.1"
  git_exec tag "v0.32.1"
  git_exec checkout master 
}

clean_repo() {
  git_exec gc --prune=now --aggressive
}

artifact_specs() {
  if [[ $CI ]]; then
    tar -czf specs.tar.gz Specs
    mv specs.tar.gz "$CIRCLE_ARTIFACTS/"
  fi
}

clone_repo
measure_repo
squash_branch "master"
measure_repo
squash_branch "predates_sharding_branch"
measure_repo
squash_branch "fix/PODS_ROOT"
measure_repo
squash_branch "revert-13358-crashlytics-3.1.0-podspec-fix"
measure_repo
squash_branch "revert-13365-revert-13358-crashlytics-3.1.0-podspec-fix"
tag_sharding_branch
measure_repo
clean_repo
measure_repo
artifact_specs
