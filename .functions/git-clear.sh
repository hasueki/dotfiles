#!/usr/bin/env bash

# Prune and delete local git branches

function git-clear() {
  git remote prune origin
  git branch -vv | grep 'origin/.*: gone]' | awk '{print $1}' | xargs git branch -D
}