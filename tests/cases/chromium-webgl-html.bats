#!/usr/bin/env bats

load ./weston-helper.sh

# note the `-td`: it allocates a pty so it keeps the container running
DOCKER_RUN='docker container run -dt --entrypoint /usr/bin/bash --name=chromium \
    -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
    -v /dev/galcore:/dev/galcore --privileged \
    --security-opt seccomp=unconfined --shm-size 256mb \
    artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/chromium-tests-imx8:stable-rc'

setup_file() {

  setup_weston

  docker container stop chromium || true
  docker container rm chromium || true

  eval "$DOCKER_RUN"

  sleep 40
}

teardown_file() {
  docker container stop chromium
  docker image rm -f "$(docker container inspect -f '{{.Image}}' chromium)"
  docker container rm chromium

  teardown_weston
}

# bats test_tags=platform:imx8
@test "Is Weston running?" {
  run weston_container_logs
  run is_weston_running
}

# bats test_tags=platform:imx8
@test "Is Chromium running?" {
  docker container ls | grep -q chromium
  status=$?

  [[ "$status" -eq 0 ]]
  echo "Chromium container is running"
}

# bats test_tags=platform:imx8
@test "WebGL test" {
  docker exec -it chromium npm test
}
