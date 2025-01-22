#!/usr/bin/env bats

load ./weston-helper.sh
load ./kernel-helper.sh

DOCKER_RUN_AM62='docker container run -d -it \
            --name=graphics-tests -v /dev:/dev --device-cgroup-rule="c 4:* rmw"  \
            --device-cgroup-rule="c 13:* rmw" --device-cgroup-rule="c 199:* rmw" \
            --device-cgroup-rule="c 226:* rmw" \
            artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/graphics-tests-am62:stable-rc'

DOCKER_RUN_IMX8='docker container run -e ACCEPT_FSL_EULA=1 -d -it --privileged \
            --name=graphics-tests -v /dev:/dev -v /tmp:/tmp \
            artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/graphics-tests-imx8:stable-rc'

DOCKER_RUN_UPSTREAM='docker container run -e ACCEPT_FSL_EULA=1 -d -it --privileged \
            --name=graphics-tests -v /dev:/dev -v /tmp:/tmp \
            artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/graphics-tests:stable-rc'

setup_file() {

  setup_weston

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

  teardown_weston
}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "Is Weston running?" {
  run weston_container_logs
  run is_weston_running
}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "Weston Simple EGL" {
  bats_require_minimum_version 1.5.0

  run -0 clean_kernel_logs
  run -124 docker container exec weston timeout 10s weston-simple-egl
  echo "Ran for 10 seconds without crashing, terminated by timeout."
  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "Weston Terminal" {
  bats_require_minimum_version 1.5.0

  run -124 docker container exec weston timeout 5s weston-terminal
  echo "Ran for 5 seconds without crashing, terminated by timeout."
}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "GLMark2" {
  SCORE_PASS_THRESHOLD=220

  run -0 clean_kernel_logs

  run docker container exec graphics-tests glmark2-es2-wayland -b shading:duration=5.0 -b build:use-vbo=false -b texture

  score=$(echo "$output" | grep -i "score" | cut -d: -f2 | xargs)

  echo "GLMark2 Score: Actual - $score vs Expected - $SCORE_PASS_THRESHOLD"

  [[ "$score" -ge "$SCORE_PASS_THRESHOLD" ]]

  run -0 gpu_kernel_logs
}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "Xwayland" {
  bats_require_minimum_version 1.5.0

  run -124 docker container exec --user torizon graphics-tests timeout 5s xterm -fa DejaVuSansMono

  echo "Ran for 5 seconds without crashing, terminated by timeout."
}
