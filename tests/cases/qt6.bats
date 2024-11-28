#!/usr/bin/env bats

load ./kernel-helper.sh

DOCKER_RUN_AM62='docker container run -d -it --net=host --name=qt6-wayland-examples \
             --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ \
             --device-cgroup-rule="c 4:* rmw"  --device-cgroup-rule="c 13:* rmw" \
             --device-cgroup-rule="c 226:* rmw" --device-cgroup-rule="c 29:* rmw" \
             artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/qt6-wayland-examples-am62:stable-rc'

DOCKER_RUN_IMX8='docker container run -d -it --net=host --name=qt6-wayland-examples \
             --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ \
             --device-cgroup-rule="c 4:* rmw"  --device-cgroup-rule="c 13:* rmw" \
             --device-cgroup-rule="c 226:* rmw" --device-cgroup-rule="c 29:* rmw" --device-cgroup-rule="c 199:* rmw" \
             artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/qt6-wayland-examples-imx8:stable-rc'

DOCKER_RUN_UPSTREAM='docker container run -d -it --net=host --name=qt6-wayland-examples \
             --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ \
             --device-cgroup-rule="c 4:* rmw"  --device-cgroup-rule="c 13:* rmw" \
             --device-cgroup-rule="c 226:* rmw" --device-cgroup-rule="c 29:* rmw" \
             artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/qt6-wayland-examples:stable-rc'

setup_file() {

  docker container stop qt6-wayland-examples || true
  docker container rm qt6-wayland-examples || true

  if [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN=$DOCKER_RUN_AM62
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN=$DOCKER_RUN_IMX8
  else
    DOCKER_RUN=$DOCKER_RUN_UPSTREAM
  fi

  eval "$DOCKER_RUN"

  ARCH=$(docker container exec qt6-wayland-examples uname -m)
  case "$ARCH" in
    aarch64)
      LIB_PATH_PREFIX="/usr/lib/aarch64-linux-gnu"
      ;;
    armv7l | armv7)
      LIB_PATH_PREFIX="/usr/lib/arm-linux-gnueabihf"
      ;;
    x86_64)
      LIB_PATH_PREFIX="/usr/lib/x86_64-linux-gnu"
      ;;
    *)
      echo "Unsupported architecture: $ARCH"
      exit 1
      ;;
  esac

  export LIB_PATH_PREFIX
}

teardown_file() {
  docker container stop qt6-wayland-examples
  docker image rm -f "$(docker container inspect -f '{{.Image}}' qt6-wayland-examples)"
  docker container rm qt6-wayland-examples
}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "EGL kmscube" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  docker container exec qt6-wayland-examples bash -c \
    "printf '#!/bin/bash\nkms-setup.sh $LIB_PATH_PREFIX/qt6/examples/opengl/cube/cube\n' > /tmp/run_kmscube.sh && chmod +x /tmp/run_kmscube.sh"

  docker container exec qt6-wayland-examples cat /tmp/run_kmscube.sh

  run timeout 10s docker container exec -e QT_QPA_PLATFORM=eglfs qt6-wayland-examples /tmp/run_kmscube.sh

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "LinuxFB shapedclock" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  RUN_LINUXFB_SHAPEDCLOCK_EXAMPLE="$LIB_PATH_PREFIX/qt6/examples/widgets/widgets/shapedclock/shapedclock"
  run -124 docker container exec -e QT_QPA_PLATFORM=linuxfb qt6-wayland-examples timeout 10s "$RUN_LINUXFB_SHAPEDCLOCK_EXAMPLE"

  run -0 gpu_kernel_logs
}
