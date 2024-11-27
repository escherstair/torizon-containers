#!/usr/bin/env bash

set_am62_variables() {
  WESTON_RUN='docker container run -d --name=weston --net=host \
          --cap-add CAP_SYS_TTY_CONFIG \
          -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ \
          --device-cgroup-rule="c 4:* rmw" --device-cgroup-rule="c 13:* rmw" \
          --device-cgroup-rule="c 10:223 rmw" --device-cgroup-rule="c 226:* rmw" \
          artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/weston-am62:stable-rc \
          --developer --tty=/dev/tty7 -- --debug'

  GRAPHICS_TESTS_RUN='docker container run -d -it --name=graphics-tests --privileged \
          -v /dev:/dev -v /tmp:/tmp  \
          --device-cgroup-rule="c 226:* rmw" \
          artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/graphics-tests-am62:stable-rc'

  QT6_WAYLAND_TESTS_RUN='docker container run --rm -d -it --name=qt6-wayland-tests \
          -v /tmp:/tmp -v /dev/dri:/dev/dri \
          --device-cgroup-rule="c 226:* rmw" \
          artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/qt6-wayland-tests-am62:stable-rc'
}

set_imx8_variables() {
  WESTON_RUN='docker container run -d --name=weston --net=host \
          --cap-add CAP_SYS_TTY_CONFIG \
          -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ \
          --device-cgroup-rule="c 4:* rmw" --device-cgroup-rule="c 13:* rmw" \
          --device-cgroup-rule="c 199:0 rmw" --device-cgroup-rule="c 10:223 rmw" \
          --device-cgroup-rule="c 226:* rmw" --device-cgroup-rule="c 253:* rmw" \
          artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/weston-imx8:stable-rc \
          --developer --tty=/dev/tty7 -- --debug'

  GRAPHICS_TESTS_RUN='docker container run -d -it --name=graphics-tests --privileged \
          -v /dev:/dev -v /tmp:/tmp  \
          --device-cgroup-rule="c 199:* rmw" --device-cgroup-rule="c 226:* rmw" \
          artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/graphics-tests-imx8:stable-rc'

  QT6_WAYLAND_TESTS_RUN='docker container run --rm -d -it --name=qt6-wayland-tests \
          -v /tmp:/tmp -v /dev/dri:/dev/dri -v /dev/galcore:/dev/galcore \
          --device-cgroup-rule="c 199:* rmw" --device-cgroup-rule="c 226:* rmw" \
          artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/qt6-wayland-tests-imx8:stable-rc'
}

set_upstream_variables() {
  WESTON_RUN='docker container run -d --name=weston --net=host \
          --cap-add CAP_SYS_TTY_CONFIG \
          -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ \
          --device-cgroup-rule="c 4:* rmw" --device-cgroup-rule="c 13:* rmw" \
          --device-cgroup-rule="c 226:* rmw" --device-cgroup-rule="c 10:223 rmw" \
          artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/weston:stable-rc \
          --developer --tty=/dev/tty7 -- --debug'

  GRAPHICS_TESTS_RUN='docker container run -d -it --name=graphics-tests --privileged \
          -v /dev:/dev -v /tmp:/tmp \
          --device-cgroup-rule="c 226:* rmw" \
          artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/graphics-tests:stable-rc'

  QT6_WAYLAND_TESTS_RUN='docker container run -d -it --name=qt6-wayland-tests \
          -v /tmp:/tmp -v /dev/dri:/dev/dri \
          --device-cgroup-rule="c 226:* rmw" \
          artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/qt6-wayland-tests:stable-rc bash'
}

setup_weston() {
  docker container stop weston || true
  docker container rm weston || true

  if [[ "$PLATFORM_FILTER" == *am62* ]]; then
    set_am62_variables
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    set_imx8_variables
  else
    set_upstream_variables
  fi

  eval "$WESTON_RUN"
  eval "$GRAPHICS_TESTS_RUN"
  eval "$QT6_WAYLAND_TESTS_RUN"

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
  for container_name in qt6-wayland-tests graphics-tests weston; do
    IMAGE_ID=$(docker container inspect -f '{{.Image}}' $container_name 2>/dev/null)

    docker container stop $container_name || true
    docker container rm $container_name || true

    if [[ -n "$IMAGE_ID" || $RM_ON_TEARDOWN == "true" ]]; then
      docker image rm -f "$IMAGE_ID" || true
    fi
  done
}
