#!/usr/bin/env bats

load ./kernel-helper.sh
load ./general-helper.sh

DOCKER_RUN_AM62="docker container run -d -it --net=host --name=qt5-wayland-examples \
             --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ \
             --device-cgroup-rule='c 4:* rmw'  --device-cgroup-rule='c 13:* rmw' \
             --device-cgroup-rule='c 226:* rmw' --device-cgroup-rule='c 29:* rmw' \
             $REGISTRY/torizon/qt5-wayland-examples-am62:stable-rc"

DOCKER_RUN_IMX8="docker container run -d -it --net=host --name=qt5-wayland-examples \
             --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ \
             --device-cgroup-rule='c 4:* rmw' --device-cgroup-rule='c 13:* rmw' \
             --device-cgroup-rule='c 226:* rmw' --device-cgroup-rule='c 29:* rmw' --device-cgroup-rule='c 199:* rmw' \
             $REGISTRY/torizon/qt5-wayland-examples-imx8:stable-rc"

DOCKER_RUN_IMX95="docker container run -d -it --net=host --name=qt5-wayland-examples \
             --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ \
             --device-cgroup-rule='c 4:* rmw' --device-cgroup-rule='c 13:* rmw' \
             --device-cgroup-rule='c 226:* rmw' --device-cgroup-rule='c 29:* rmw' --device-cgroup-rule='c 199:* rmw' \
             $REGISTRY/torizon/qt5-wayland-examples-imx95:stable-rc"

DOCKER_RUN_UPSTREAM="docker container run -d -it --net=host --name=qt5-wayland-examples \
             --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ \
             --device-cgroup-rule='c 4:* rmw' --device-cgroup-rule='c 13:* rmw' \
             --device-cgroup-rule='c 226:* rmw' --device-cgroup-rule='c 29:* rmw' \
             $REGISTRY/torizon/qt5-wayland-examples:stable-rc"

setup_file() {

  docker container kill qt5-wayland-examples || true
  docker container rm qt5-wayland-examples || true

  if [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN=$DOCKER_RUN_AM62
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN=$DOCKER_RUN_IMX8
  elif [[ "$PLATFORM_FILTER" == *imx95* ]]; then
    DOCKER_RUN=$DOCKER_RUN_IMX95
  else
    DOCKER_RUN=$DOCKER_RUN_UPSTREAM
  fi

  eval "$DOCKER_RUN"

  ARCH=$(docker container exec qt5-wayland-examples uname -m)
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
  cleanup_container qt5-wayland-examples
}

# bats test_tags=platform:imx8, platform:imx95, platform:am62, platform:upstream
@test "Qt5 EGL kmscube runs" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs

  docker container exec qt5-wayland-examples bash -c \
    "printf '#!/bin/bash\nkms-setup.sh $LIB_PATH_PREFIX/qt5/examples/opengl/cube/cube\n' > /tmp/run_kmscube.sh && chmod +x /tmp/run_kmscube.sh"

  docker container exec qt5-wayland-examples cat /tmp/run_kmscube.sh

  run timeout 10s docker container exec -e QT_QPA_PLATFORM=eglfs qt5-wayland-examples /tmp/run_kmscube.sh

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8, platform:imx95, platform:am62, platform:upstream
@test "Qt5 LinuxFB shapedclock runs" {
  bats_require_minimum_version 1.5.0

  RUN_LINUXFB_SHAPEDCLOCK_EXAMPLE="$LIB_PATH_PREFIX/qt5/examples/widgets/widgets/shapedclock/shapedclock"

  run -0 clean_kernel_logs

  run -124 docker container exec -e QT_QPA_PLATFORM=linuxfb qt5-wayland-examples timeout 10s "$RUN_LINUXFB_SHAPEDCLOCK_EXAMPLE"

  run -0 gpu_kernel_logs
}
