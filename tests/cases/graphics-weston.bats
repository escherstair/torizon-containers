#!/usr/bin/env bats

bats_load_library bats-support
bats_load_library bats-assert

load ./weston-helper.sh

setup_file() {
  setup_weston
}

teardown_file() {
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

  run -124 docker container exec weston timeout 10s weston-simple-egl
  echo "Ran for 10 seconds without crashing, terminated by timeout."
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

  run docker container exec graphics-tests glmark2-es2-wayland -b shading:duration=5.0 -b build:use-vbo=false -b texture

  score=$(echo "$output" | grep -i "score" | cut -d: -f2 | xargs)

  echo "GLMark2 Score: Actual - $score vs Expected - $SCORE_PASS_THRESHOLD"

  [[ "$score" -ge "$SCORE_PASS_THRESHOLD" ]]
}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "Xwayland" {
  bats_require_minimum_version 1.5.0

  run -124 docker container exec --user torizon graphics-tests timeout 5s xterm -fa DejaVuSansMono

  echo "Ran for 5 seconds without crashing, terminated by timeout."
}

# bats test_tags=platform:imx8, platform:am62, platform:upstream
@test "QT6 wayland" {
  bats_require_minimum_version 1.5.0

  run docker container exec qt6-wayland-tests contextinfo

  assert_output --regexp "OpenGL Version: OpenGL ES [23]\.[02].*"
}
