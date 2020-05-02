#!/usr/bin/env bash

# Switch IKS kube context with pre-defined default list

function kubesw() {
  local ALIAS_FILE=~/.kubesw_alias
  local IKS_CLUSTERS_DIR=~/.bluemix/plugins/container-service/clusters

  local usage() {
    echo 'NAME:'
    echo 'kubesw - A command-line utility to switch IKS kube context'
    echo
    echo 'USAGE:'
    echo 'kubesw <env-alias>'
    echo 'kubesw --all'
    echo 'kubesw --fetch'
    echo 'kubesw --set-alias'
    echo 'kubesw --prune'
    echo
  }

  local fetch() {
    # Set extra args
    local FLAGS="--admin"

    # Select account
    local IC_ACCOUNT=$(ibmcloud account list | fzf --header-lines=3 --height 20% --reverse | awk '{print $1}')

    if [ ! -z "$IC_ACCOUNT" ]
    then
      # Target account
      ibmcloud target -c $IC_ACCOUNT

      # Select cluster
      local CLUSTER=$(ibmcloud ks cluster ls | fzf --header-lines=2 --height 20% --reverse | awk '{print $1}')

      if [ ! -z "$CLUSTER" ]
      then
        # Get kube context for cluster
        unset KUBECONFIG
        ibmcloud ks cluster config --cluster $CLUSTER $FLAGS
      fi
    fi
  }

  local setalias() {
    local CLUSTER=$(ls $IKS_CLUSTERS_DIR | fzf --header="Select target cluster to set alias:" --height 20% --reverse)
    if [ ! -z "$CLUSTER" ]
    then
      read "ALIAS?Enter alias name for $CLUSTER: "
      local EXIST=$(cat $ALIAS_FILE | grep "$ALIAS :")
      if [ ! -z "$EXIST" ]
      then
        local EXIST_CLUSTER=$(awk '{print $3}' <<< $EXIST)
        read "PROMPT?Overwrite existing alias set to "$EXIST_CLUSTER"? <y/N> "
        if [[ $PROMPT =~ [yY](es)* ]]
        then
          sed -i.bk "s/$EXIST/$ALIAS : $CLUSTER/" $ALIAS_FILE
        fi
      else
        echo "$ALIAS : $CLUSTER" >> $ALIAS_FILE
      fi
      echo "\nCurrent aliases:"
      cat $ALIAS_FILE
    fi
  }

  local prune() {
    # Set timeout for check
    local TIMEOUT=5

    # Check each cluster in folder
    for EACH in $(ls $IKS_CLUSTERS_DIR)
    do
      echo "Checking: $EACH"
      # Run cmd to check validity
      local CHECK=$(KUBECONFIG=$(ls $IKS_CLUSTERS_DIR/$EACH/*.yml) gtimeout --kill-after=$TIMEOUT $TIMEOUT kubectl get nodes)
      if [ -z "$CHECK" ] || [ "$CHECK" == *"Unable to connect to the server"* ] # Timed out or cannot connect
      then
        echo "Pruning:  $EACH\n"
        rm -rf $IKS_CLUSTERS_DIR/$EACH
      else
        echo "Success:  $EACH\n"
      fi
    done
  }

  for arg in "$@"
  do
    if [ "$arg" == "--all" ] || [ "$arg" == "-a" ]
    then
      local CLUSTER_NAME=$(ls $IKS_CLUSTERS_DIR | fzf --height 20% --reverse)
      if [ ! -z "$CLUSTER_NAME" ]
      then
        export KUBECONFIG=$(ls $IKS_CLUSTERS_DIR/$CLUSTER_NAME/*.yml)
      fi
      return
    fi
    if [ "$arg" == "--fetch" ] || [ "$arg" == "-f" ]
    then
      fetch
      return
    fi
    if [ "$arg" == "--set-alias" ] || [ "$arg" == "-s" ]
    then
      setalias
      return
    fi
    if [ "$arg" == "--prune" ] || [ "$arg" == "-p" ]
    then
      prune
      return
    fi
    if [ "$arg" == "--help" ] || [ "$arg" == "-h" ]
    then
      usage
      return
    fi
  done

  if [ -f "$ALIAS_FILE" ]
  then
    local ALIASES=$(cat $ALIAS_FILE)
    while read -r env
    do
      local ENV_ALIAS=$(awk '{print $1}' <<< $env)
      local CLUSTER_NAME=$(awk '{print $3}' <<< $env)
      if [ "$ENV_ALIAS" == "$1" ]
      then
        export KUBECONFIG=$(ls $IKS_CLUSTERS_DIR/$CLUSTER_NAME/*.yml)
        return
      fi
    done <<< $ALIASES

    local ALIAS=$(fzf --height 20% --reverse <<< $ALIASES | awk '{print $1}')
    if [ ! -z "$ALIAS" ]
    then
      kubesw $ALIAS
    fi
    return
  fi
}