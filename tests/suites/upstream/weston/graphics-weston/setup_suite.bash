setup_suite() {
    docker container stop weston || true
    docker container rm weston || true

    for dir in /sys/class/drm/card*-HDMI-*; do
        if [[ -d $dir ]]; then
            echo "on" > "$dir/status"
        fi
    done

    docker container run -d --name=weston --net=host \
    --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp \
    -v /run/udev/:/run/udev/ --device-cgroup-rule="c 4:* rmw" \
    --device-cgroup-rule="c 13:* rmw" --device-cgroup-rule="c 226:* rmw" \
    --device-cgroup-rule="c 10:223 rmw" \
    torizon/weston:stable-rc \
    --developer --tty=/dev/tty7 -- --debug

    sleep 10

    docker container stop graphics-tests || true
    docker container rm graphics-tests || true

    docker container run -e ACCEPT_FSL_EULA=1 -d -it \
    --name=graphics-tests -v /dev:/dev -v /tmp:/tmp --device-cgroup-rule="c 4:* rmw"  \
    --device-cgroup-rule="c 13:* rmw" \
    --device-cgroup-rule="c 226:* rmw" \
    torizon/graphics-tests:stable-rc
}

teardown_suite() {
    docker container stop weston
    docker image rm -f $(docker container inspect -f '{{.Image}}' weston)
    docker container rm weston

    docker container stop graphics-tests
    docker image rm -f $(docker container inspect -f '{{.Image}}' graphics-tests)
    docker container rm graphics-tests

    for dir in /sys/class/drm/card*-HDMI-*; do
        if [[ -d $dir ]]; then
            echo "off" > "$dir/status"
        fi
    done
}
