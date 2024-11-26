#!/usr/bin/env bats

load ./weston-helper.sh
load ./image-comparison.sh

DOCKER_RUN_AM62='docker container run -d --name=chromium \
    -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
    -v /dev/dri:/dev/dri --device-cgroup-rule="c 226:* rmw" \
    --security-opt seccomp=unconfined --shm-size 256mb \
    artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/chromium-am62:stable-rc \
    --virtual-keyboard http://info.cern.ch/hypertext/WWW/TheProject.html'

DOCKER_RUN_IMX8='docker container run -d --name=chromium \
    -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
    -v /dev/galcore:/dev/galcore --device-cgroup-rule="c 199:* rmw" \
    --security-opt seccomp=unconfined --shm-size 256mb \
    artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/chromium-imx8:stable-rc \
    --virtual-keyboard http://info.cern.ch/hypertext/WWW/TheProject.html'

DOCKER_RUN_UPSTREAM='docker container run -d --name=chromium \
    -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
    -v /dev/dri:/dev/dri --device-cgroup-rule="c 226:* rmw" \
    --security-opt seccomp=unconfined --shm-size 256mb \
    artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/chromium:stable-rc \
    --virtual-keyboard http://info.cern.ch/hypertext/WWW/TheProject.html'

setup_file() {

  setup_weston

  docker container stop chromium || true
  docker container rm chromium || true

  if [[ "$PLATFORM_FILTER" == *am62* ]]; then
    DOCKER_RUN=$DOCKER_RUN_AM62
  elif [[ "$PLATFORM_FILTER" == *imx8* ]]; then
    DOCKER_RUN=$DOCKER_RUN_IMX8
  else
    DOCKER_RUN=$DOCKER_RUN_UPSTREAM
  fi

  eval "$DOCKER_RUN"

  sleep 40
}

teardown_file() {
  docker container stop chromium
  docker image rm -f "$(docker container inspect -f '{{.Image}}' chromium)"
  docker container rm chromium

  teardown_weston
}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "Is Weston running?" {
  run weston_container_logs
  run is_weston_running
}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "Is Chromium running?" {
  docker container ls | grep -q chromium
  status=$?

  [[ "$status" -eq 0 ]]
  echo "Chromium container is running"
}

# FIXME: this test has to be refactored/re-enabled when Chromium is worked on.
# bats test_tags=platform:imx8, platform:am62, platform:upstream
# @test "Chromium" {
#     take_screenshot "weston"
#     copy_screenshot "weston"
#     image_compare ... 100
# }
