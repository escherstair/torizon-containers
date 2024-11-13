#!/usr/bin/env bats

@test "Is Weston running?" {
    docker container ls | grep -q weston
    status=$?

    [[ "$status" -eq 0 ]]
    echo "Weston container is running"
}

# note that adding screenshot comparison tests here must be done carefully, as
# we don't necessarily close the windows for the tests below.

# using the built-in `timeout` as a pretty decent way to test non-returning commands.
@test "Weston Simple EGL" {
    run timeout 10s docker container exec weston weston-simple-egl
    # Check if the command was terminated by timeout (exit code 124) or succeeded (exit code 0)
    if [ "$status" -eq 124 ]; then
        echo "Ran for 10 seconds without crashing, terminated by timeout."
    else
        [ "$status" -eq 0 ]
    fi
}

@test "Weston Terminal" {
    run timeout 5s docker container exec weston weston-terminal
    # Check if the command was terminated by timeout (exit code 124) or succeeded (exit code 0)
    if [ "$status" -eq 124 ]; then
        echo "Ran for 5 seconds without crashing, terminated by timeout."
    else
        [ "$status" -eq 0 ]
    fi
}

@test "GLMark2" {
    SCORE_PASS_THRESHOLD=220

    run docker container exec graphics-tests glmark2-es2-wayland -b shading:duration=5.0 -b build:use-vbo=false -b texture

    score=$(echo "$output" | grep -i "score" | cut -d: -f2 | xargs)

    echo "GLMark2 Score: Actual - $score vs Expected - $SCORE_PASS_THRESHOLD"

    [[ "$score" -ge "$SCORE_PASS_THRESHOLD" ]]
}

@test "Xwayland" {
    bats_require_minimum_version 1.5.0

    run -124 timeout 5s docker container exec --user torizon graphics-tests xterm

    echo "Ran for 5 seconds without crashing, terminated by timeout."
}
