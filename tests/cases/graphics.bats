#!/usr/bin/env bats

load ./kernel-helper.sh

DOCKER_RUN_AM62='docker container run -d -it \
            --name=graphics-tests -v /dev:/dev --device-cgroup-rule="c 4:* rmw"  \
            --device-cgroup-rule="c 13:* rmw" --device-cgroup-rule="c 199:* rmw" \
            --device-cgroup-rule="c 226:* rmw" \
            $REGISTRY/torizon/graphics-tests-am62:stable-rc'

DOCKER_RUN_IMX8='docker container run -e ACCEPT_FSL_EULA=1 -d -it --privileged \
            --name=graphics-tests -v /dev:/dev -v /tmp:/tmp \
            $REGISTRY/torizon/graphics-tests-imx8:stable-rc'

DOCKER_RUN_UPSTREAM='docker container run -e ACCEPT_FSL_EULA=1 -d -it --privileged \
            --name=graphics-tests -v /dev:/dev -v /tmp:/tmp \
            $REGISTRY/torizon/graphics-tests:stable-rc'

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
}

teardown_file() {
  docker container stop graphics-tests
  docker image rm -f "$(docker container inspect -f '{{.Image}}' graphics-tests)"
  docker container rm graphics-tests
}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "Check if base container is running" {
  status=$(docker container ls | grep -q graphics-tests)
  if [ "$status" -ne 0 ]; then
    echo "Base container is not running"
    result=1
  else
    echo "Base container is running"
    result=0
  fi
  [ "$result" -eq 0 ]

}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "Test kmscube" {
  run -0 clean_kernel_logs

  docker container exec -it graphics-tests kmscube -c 2048 -D /dev/dri/card0 | tee /tmp/kmscube.txt

  FPSs=$(grep 'fps)' /tmp/kmscube.txt | cut -d '(' -f 2 | cut -d ' ' -f 1)
  for FPS in $FPSs; do
    [ 1 -eq "$(echo "$FPS >= 55" | bc)" ] && [ 1 -eq "$(echo "$FPS < 100" | bc)" ]
  done

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "Modetest" {
  docker container exec graphics-tests modetest
}

# autodetection is frail for imx-drm
# bats test_tags=platform:imx8
@test "Modetest iMX8" {
  docker container exec graphics-tests modetest -M imx-drm
}

# bats test_tags=platform:imx8
@test "Test gputop" {
  docker container exec graphics-tests gputop -b -f
}
