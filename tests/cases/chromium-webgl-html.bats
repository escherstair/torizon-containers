#!/usr/bin/env bats

load ./weston-helper.sh

# note the `-td`: it allocates a pty so it keeps the container running
DOCKER_RUN='docker container run -td --name=chromium-tests --entrypoint /usr/bin/bash \
    -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
    -v /dev:/dev --device-cgroup-rule="c 199:* rmw" \
    --device-cgroup-rule="c 81:* rmw" --device-cgroup-rule="c 234:* rmw" \
    --device-cgroup-rule="c 253:* rmw"  --device-cgroup-rule="c 226:* rmw" \
    --device-cgroup-rule="c 235:* rmw" \
    --security-opt seccomp=unconfined --shm-size 256mb \
    $REGISTRY/torizon/chromium-tests-imx8:stable-rc'

setup_file() {

  setup_weston

  docker container stop chromium-tests || true
  docker container rm chromium-tests || true

  eval "$DOCKER_RUN"

  sleep 40
}

teardown_file() {
  docker container stop chromium-tests
  docker image rm -f "$(docker container inspect -f '{{.Image}}' chromium-tests)"
  docker container rm chromium-tests

  teardown_weston
}

# bats test_tags=platform:imx8
@test "Is Weston running?" {
  run weston_container_logs
  run is_weston_running
}

# bats test_tags=platform:imx8
@test "Is Chromium running?" {
  docker container ls | grep -q chromium-tests
  status=$?

  [[ "$status" -eq 0 ]]
  echo "chromium-tests container is running"
}

# bats test_tags=platform:imx8
@test "WebGL test" {
  docker exec chromium-tests npm test
}
