#!/usr/bin/env bash

setup_weston() {
  local WESTON_RUN_AM62="docker container run -d --name=weston --net=host \
        --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp \
        -v /run/udev/:/run/udev/ --device-cgroup-rule='c 4:* rmw' \
        --device-cgroup-rule='c 13:* rmw' --device-cgroup-rule='c 226:* rmw' \
        --device-cgroup-rule='c 10:223 rmw' \
        $REGISTRY/torizon/weston-am62:stable-rc \
        --developer --tty=/dev/tty7 -- --debug"

  local WESTON_RUN_IMX8="docker container run -d --name=weston --net=host \
        --cap-add CAP_SYS_TTY_CONFIG \
        -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ \
        --device-cgroup-rule='c 4:* rmw' --device-cgroup-rule='c 253:* rmw' \
        --device-cgroup-rule='c 13:* rmw' --device-cgroup-rule='c 226:* rmw' \
        --device-cgroup-rule='c 10:223 rmw' --device-cgroup-rule='c 199:0 rmw' \
        $REGISTRY/torizon/weston-imx8:stable-rc \
        --developer --tty=/dev/tty7 -- --debug"

  local WESTON_RUN_IMX95="docker container run -d --name=weston --net=host \
        --cap-add CAP_SYS_TTY_CONFIG \
        -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ \
        --device-cgroup-rule='c 4:* rmw' --device-cgroup-rule='c 253:* rmw' \
        --device-cgroup-rule='c 13:* rmw' --device-cgroup-rule='c 226:* rmw' \
        --device-cgroup-rule='c 10:223 rmw' --device-cgroup-rule='c 199:0 rmw' \
        $REGISTRY/torizon/weston-imx95:stable-rc \
        --developer --tty=/dev/tty7 -- --debug"

  local WESTON_RUN_UPSTREAM="docker container run -d --name=weston --net=host \
        --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp \
        -v /run/udev/:/run/udev/ --device-cgroup-rule='c 4:* rmw' \
        --device-cgroup-rule='c 13:* rmw' --device-cgroup-rule='c 226:* rmw' \
        --device-cgroup-rule='c 10:223 rmw' \
        $REGISTRY/torizon/weston:stable-rc \
        --developer --tty=/dev/tty7 -- --debug"

  docker container stop weston || true
  docker container rm weston || true

  local DOCKER_RUN
  if [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN="$WESTON_RUN_AM62"
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN="$WESTON_RUN_IMX8"
  elif [[ "$PLATFORM_FILTER" == *imx95* ]]; then
    DOCKER_RUN=$WESTON_RUN_IMX95
  else
    DOCKER_RUN="$WESTON_RUN_UPSTREAM"
  fi

  eval "$DOCKER_RUN"

  sleep 30
}

weston_container_logs() {
  docker logs weston
}

is_weston_running() {
  docker container ls | grep -q weston
  status=$?

  if [[ "$status" -ne 0 ]]; then
    echo "Weston container is not running"
    exit 1
  else
    echo "Weston container is running"
  fi
}

teardown_weston() {
  docker container stop weston || true

  IMAGE_ID=$(docker container inspect -f '{{.Image}}' weston 2>/dev/null)
  if [[ -n "$IMAGE_ID" ]]; then
    docker image rm -f "$IMAGE_ID" || true
  fi

  docker container rm weston || true
}
