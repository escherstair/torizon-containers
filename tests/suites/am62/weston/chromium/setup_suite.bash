setup_suite() {

    for dir in /sys/class/drm/card*-HDMI-*; do
        if [[ -d $dir ]]; then
            echo "on" > "$dir/status"
        fi
    done

    docker container stop weston || true
    docker container rm weston || true

    docker container run -d --name=weston --net=host \
    --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp \
    -v /run/udev/:/run/udev/ \
    --device-cgroup-rule="c 4:* rmw" --device-cgroup-rule="c 13:* rmw" \
    --device-cgroup-rule="c 226:* rmw" --device-cgroup-rule="c 10:223 rmw" \
    torizon/weston-am62:next --developer --tty=/dev/tty7 -- --debug

    sleep 10

    docker container stop chromium || true
    docker container rm chromium || true

    # FIXME: healthchecks instead of sleep
    docker container run -d --name=chromium \
    -v /tmp:/tmp -v /var/run/dbus:/var/run/dbus \
    -v /dev/dri:/dev/dri --device-cgroup-rule='c 226:* rmw' \
    --security-opt seccomp=unconfined --shm-size 256mb \
    torizon/chromium-am62:next \
    --virtual-keyboard http://info.cern.ch/hypertext/WWW/TheProject.html

    # chromium can take a while to fully load
    sleep 30
}

teardown_suite() {
    docker container stop weston

    if [ -z "$DO_NOT_RM_ON_TEARDOWN" ]; then
        docker image rm -f $(docker container inspect -f '{{.Image}}' weston)
    else
        echo "Skipping Docker image removal due to DO_NOT_RM_ON_TEARDOWN environment variable."
    fi

    docker container rm weston

    docker container stop chromium

    if [ -z "$DO_NOT_RM_ON_TEARDOWN" ]; then
        docker image rm -f $(docker container inspect -f '{{.Image}}' chromium)
    else
        echo "Skipping Docker image removal due to DO_NOT_RM_ON_TEARDOWN environment variable."
    fi

    docker container rm chromium

    for dir in /sys/class/drm/card*-HDMI-*; do
        if [[ -d $dir ]]; then
            echo "off" > "$dir/status"
        fi
    done
}
