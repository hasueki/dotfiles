#!/usr/bin/env bash

# Encrypt and decrypt strings using standard library

function crypt() {

  local usage() {
    echo 'NAME:'
    echo 'crypt - A command-line utility to encrypt and decrypt using node-common security library'
    echo ''
    echo 'USAGE:'
    echo 'crypt [--encrypt|-e] <string>'
    echo 'crypt [--decrypt|-d] <encrypted string>'
    echo 'crypt [--init|-i]'
    echo ''
  }

  local config=~/.standard_crypt
  local module=~/git/bluemix-native-apim/node-common/lib/security

  for arg in "$@"
  do
    if [ "$arg" == "--decrypt" ] || [ "$arg" == "-d" ]
    then
      local mode='decrypt'
    fi
    if [ "$arg" == "--encrypt" ] || [ "$arg" == "-e" ]
    then
      local mode='encrypt'
    fi
    if [ "$arg" == "--init" ] || [ "$arg" == "-i" ]
    then
      rm -f $config
    fi
    if [ "$arg" == "--help" ] || [ "$arg" == "-h" ]
    then
      usage
      return
    fi
  done

  if [ ! -f $config ]
  then
    read 'iv?Enter initialization vector (IV): '
    read 'key?Enter KEY: '
    echo ''
    echo "$iv\n$key" > $config
  fi

  local IV=$(sed -n '1p' < $config)
  local KEY=$(sed -n '2p' < $config)

  if [ ! -z "$mode" ]
  then
    STANDARD_CRYPT__IV=$IV STANDARD_CRYPT__KEY=$KEY node -p "require('$module').$mode('$2')"
  else
    usage
  fi
}