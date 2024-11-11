setup_suite() {
    docker container stop qt5-wayland-examples || true
    docker container rm qt5-wayland-examples || true

    docker container run -d -it --net=host --name=qt5-wayland-examples \
             --cap-add CAP_SYS_TTY_CONFIG -v /dev:/dev -v /tmp:/tmp -v /run/udev/:/run/udev/ \
             --device-cgroup-rule="c 4:* rmw"  --device-cgroup-rule="c 13:* rmw" \
             --device-cgroup-rule="c 226:* rmw" --device-cgroup-rule="c 29:* rmw" \
             artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/qt5-wayland-examples-imx8:stable-rc
}

teardown_suite() {
    docker container stop qt5-wayland-examples
    docker image rm -f $(docker container inspect -f '{{.Image}}' qt5-wayland-examples)
    docker container rm qt5-wayland-examples
}
