setup_suite() {
    docker container stop weston || true
    docker container rm weston || true

    docker container run -d --name=weston --net=host \
    --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp \
    -v /run/udev/:/run/udev/ --device-cgroup-rule="c 4:* rmw" \
    --device-cgroup-rule="c 13:* rmw" --device-cgroup-rule="c 226:* rmw" \
    --device-cgroup-rule="c 199:* rmw" --device-cgroup-rule="c 10:223 rmw" \
    artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/weston-imx8:stable-rc \
    --developer --tty=/dev/tty7 -- --debug

    sleep 10

    docker container stop gtk3-tests || true
    docker container rm gtk3-tests || true

    docker container run -d -it \
    --name=gtk3-tests -v /dev:/dev -v /tmp:/tmp \
    --device-cgroup-rule="c 4:* rmw"  \
    --device-cgroup-rule="c 13:* rmw" \
    --device-cgroup-rule="c 199:* rmw" \
    --device-cgroup-rule="c 226:* rmw" \
    artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/gtk3-tests-imx8:stable-rc bash
}

teardown_suite() {
    docker container stop weston
    docker image rm -f $(docker container inspect -f '{{.Image}}' weston-imx8)
    docker container rm weston

    docker container stop gtk3-tests
    docker image rm -f $(docker container inspect -f '{{.Image}}' gtk3-tests-imx8)
    docker container rm gtk3-tests

}
