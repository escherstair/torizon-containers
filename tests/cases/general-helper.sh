#!/usr/bin/env bash

check_if_base_container_runs() {
  local container_name="$1"

  docker container ls | grep -q "$container_name"
  local status=$?

  if [[ "$status" -ne 0 ]]; then
    echo "Base container '$container_name' is not running"
    exit 1
  fi
}

cleanup_container() {
  local container_name="$1"

  docker container kill "$container_name"
  docker image rm -f "$(docker container inspect -f '{{.Image}}' "$container_name")"
  docker container rm "$container_name"
}
