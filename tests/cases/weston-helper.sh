#!/usr/bin/env bash

setup_weston() {
  WESTON_RUN_AM62='docker container run -d --name=weston --net=host \
        --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp \
        -v /run/udev/:/run/udev/ --device-cgroup-rule="c 4:* rmw" \
        --device-cgroup-rule="c 13:* rmw" --device-cgroup-rule="c 226:* rmw" \
        --device-cgroup-rule="c 10:223 rmw" \
        artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/weston-am62:stable-rc \
        --developer --tty=/dev/tty7 -- --debug'

  WESTON_RUN_IMX8='docker container run -d --name=weston --net=host \
        --cap-add CAP_SYS_TTY_CONFIG \
        -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ \
        --device-cgroup-rule="c 4:* rmw" --device-cgroup-rule="c 253:* rmw" \
        --device-cgroup-rule="c 13:* rmw" --device-cgroup-rule="c 226:* rmw" \
        --device-cgroup-rule="c 10:223 rmw" --device-cgroup-rule="c 199:0 rmw" \
        artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/weston-imx8:stable-rc \
        --developer --tty=/dev/tty7 -- --debug'

  WESTON_RUN_UPSTREAM='docker container run -d --name=weston --net=host \
        --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp \
        -v /run/udev/:/run/udev/ --device-cgroup-rule="c 4:* rmw" \
        --device-cgroup-rule="c 13:* rmw" --device-cgroup-rule="c 226:* rmw" \
        --device-cgroup-rule="c 10:223 rmw" \
        artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/weston:stable-rc \
        --developer --tty=/dev/tty7 -- --debug'

  docker container stop weston || true
  docker container rm weston || true

  if [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN="$WESTON_RUN_AM62"
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN="$WESTON_RUN_IMX8"
  else
    DOCKER_RUN="$WESTON_RUN_UPSTREAM"
  fi

  eval "$DOCKER_RUN"

  sleep 30
}

teardown_weston() {
  docker container stop weston || true

  IMAGE_ID=$(docker container inspect -f '{{.Image}}' weston 2>/dev/null)
  if [[ -n "$IMAGE_ID" ]]; then
    docker image rm -f "$IMAGE_ID" || true
  fi

  docker container rm weston || true
}
