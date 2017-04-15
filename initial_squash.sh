#!/usr/bin/env bash

set -e
set -o pipefail
set -x

clone_repo() {
  echo "> Cloning CocoaPods/Specs"
  git clone https://github.com/CocoaPods/Specs.git Specs
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
  pushd Specs
  git_exec checkout --orphan "new_$BRANCH_NAME"
  git_exec add .
  git_exec commit -m "Squashed!"
  git_exec branch -D "$BRANCH_NAME"
  git_exec checkout -b "$BRANCH_NAME"
  git_exec branch -D "new_$BRANCH_NAME"
  git_exec checkout master
  popd
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

clone_repo
measure_repo
squash_branch "master"
squash_branch "predates_sharding_branch"
tag_sharding_branch
measure_repo
clean_repo
measure_repo
