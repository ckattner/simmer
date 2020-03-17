#!/bin/bash

error(){
  echo "$1" >&2
}

output(){
  echo "$1"
}

output "output to stdout"
error "output to sterr"

exit $1
