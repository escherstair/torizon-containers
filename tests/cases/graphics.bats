#!/usr/bin/env bats

load ./kernel-helper.sh
load ./general-helper.sh

DOCKER_RUN_AM62="docker container run -d -it \
            --name=graphics-tests -v /dev:/dev --device-cgroup-rule='c 4:* rmw'  \
            --device-cgroup-rule='c 13:* rmw' --device-cgroup-rule='c 199:* rmw' \
            --device-cgroup-rule='c 226:* rmw' \
            $REGISTRY/torizon/graphics-tests-am62:stable-rc"

DOCKER_RUN_IMX8="docker container run -e ACCEPT_FSL_EULA=1 -d -it --privileged \
            --name=graphics-tests -v /dev:/dev -v /tmp:/tmp \
            $REGISTRY/torizon/graphics-tests-imx8:stable-rc"

DOCKER_RUN_UPSTREAM="docker container run -e ACCEPT_FSL_EULA=1 -d -it --privileged \
            --name=graphics-tests -v /dev:/dev -v /tmp:/tmp \
            $REGISTRY/torizon/graphics-tests:stable-rc"

setup_file() {
  docker container stop graphics-tests || true
  docker container rm graphics-tests || true

  if [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN=$DOCKER_RUN_AM62
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN=$DOCKER_RUN_IMX8
  else
    DOCKER_RUN=$DOCKER_RUN_UPSTREAM
  fi

  eval "$DOCKER_RUN"

  sleep 10

  check_if_base_container_runs graphics-tests
}

teardown_file() {
  cleanup_container graphics-tests
}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "kmscube has sufficient score" {
  run -0 clean_kernel_logs

  docker container exec -it graphics-tests kmscube -c 2048 -D /dev/dri/card0 | tee /tmp/kmscube.txt

  FPSs=$(grep 'fps)' /tmp/kmscube.txt | cut -d '(' -f 2 | cut -d ' ' -f 1)
  for FPS in $FPSs; do [ 1 -eq "$(echo "$FPS >= 55" | bc)" ]; done

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:am62, platform:upstream
@test "Modetest is able to probe DRM information " {
  docker container exec graphics-tests modetest
}

# autodetection is frail for imx-drm
# bats test_tags=platform:imx8
@test "Modetest is able to probe DRM information" {
  docker container exec graphics-tests modetest -M imx-drm
}

# bats test_tags=platform:imx8
@test "gputop runs" {
  docker container exec graphics-tests gputop -b -f
}
