#!/usr/bin/env bats

load ./weston-helper.sh

DOCKER_RUN_AM62='docker container run -d -it \
    --name=gtk3-tests -v /dev:/dev -v /tmp:/tmp \
    --device-cgroup-rule="c 4:* rmw"  \
    --device-cgroup-rule="c 13:* rmw" \
    --device-cgroup-rule="c 226:* rmw" \
    artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/gtk3-tests-am62:stable-rc bash'

DOCKER_RUN_IMX8='docker container run -d -it \
    --name=gtk3-tests -v /dev:/dev -v /tmp:/tmp \
    --device-cgroup-rule="c 4:* rmw"  \
    --device-cgroup-rule="c 13:* rmw" \
    --device-cgroup-rule="c 199:* rmw" \
    --device-cgroup-rule="c 226:* rmw" \
    artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/gtk3-tests-imx8:stable-rc bash'

DOCKER_RUN_UPSTREAM='docker container run -d -it \
    --name=gtk3-tests -v /dev:/dev -v /tmp:/tmp \
    --device-cgroup-rule="c 4:* rmw"  \
    --device-cgroup-rule="c 13:* rmw" \
    --device-cgroup-rule="c 226:* rmw" \
    artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/gtk3-tests:stable-rc bash'

setup_file() {

  setup_weston

  docker container stop gtk3-tests || true
  docker container rm gtk3-tests || true

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
  docker container stop gtk3-tests
  docker image rm -f "$(docker container inspect -f '{{.Image}}' gtk3-tests)"
  docker container rm gtk3-tests

  teardown_weston
}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "Is Weston running?" {
  run is_weston_running
}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "Check if gtk3 container is running" {
  docker container ls | grep -q gtk3-tests
  status=$?

  if [[ "$status" -ne 0 ]]; then
    echo "GTK 3 container is not running"
    exit 1
  else
    echo "GTK 3 container is running"
  fi
}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "Simple GTK 3 test" {
  bats_require_minimum_version 1.5.0

  RUN_SIMPLE_GTK_3_TEST='simple-gtk3-test'

  run -124 docker container exec gtk3-tests timeout 10s $RUN_SIMPLE_GTK_3_TEST

  echo $status

  echo "Ran for 10 seconds without crashing, terminated by timeout."
}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "GTK 3 example" {
  bats_require_minimum_version 1.5.0

  RUN_GTK_3_EXAMPLE='gtk3-icon-browser'

  run -124 docker container exec gtk3-tests timeout 10s $RUN_GTK_3_EXAMPLE

  echo $status

  echo "Ran for 10 seconds without crashing, terminated by timeout."
}
