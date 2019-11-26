#!/usr/bin/env bash

# Switch IKS kube context with pre-defined default list

function kubesw() {

  local usage() {
    echo 'NAME:'
    echo 'kubesw - A command-line utility to switch IKS kube context'
    echo ''
    echo 'USAGE:'
    echo 'kubesw <env-alias>'
    echo 'kubesw --all'
    echo ''
  }

  local IKS_CLUSTERS_DIR=~/.bluemix/plugins/container-service/clusters

  for arg in "$@"
  do
    if [ "$arg" == "--all" ] || [ "$arg" == "-a" ]
    then
      local CLUSTER_NAME=$(ls $IKS_CLUSTERS_DIR | fzf --reverse)
      if [ ! -z "$CLUSTER_NAME" ]
      then
        export KUBECONFIG=$(ls $IKS_CLUSTERS_DIR/$CLUSTER_NAME/*.yml)
      fi
      return
    fi
    if [ "$arg" == "--help" ] || [ "$arg" == "-h" ]
    then
      usage
      return
    fi
  done

  local ENVS="dev : cluster_name
us-stage : cluster_name
eu-stage : cluster_name
us-prod : cluster_name
eu-prod : cluster_name
au-prod : cluster_name
de-prod : cluster_name
wdc-prod : cluster_name
jp-prod : cluster_name
devops : cluster_name"

  while read -r env
  do
    local ENV_ALIAS=$(awk '{print $1}' <<< $env)
    local CLUSTER_NAME=$(awk '{print $3}' <<< $env)
    if [ "$ENV_ALIAS" == "$1" ]
    then
      export KUBECONFIG=$(ls $IKS_CLUSTERS_DIR/$CLUSTER_NAME/*.yml)
      return
    fi
  done <<< $ENVS

  kubesw $(fzf --height 20% --reverse <<< $ENVS | awk '{print $1}')
}