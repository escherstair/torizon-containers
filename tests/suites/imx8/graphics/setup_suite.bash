setup_suite() {
    docker container stop graphics-tests || true
    docker container rm graphics-tests || true

    docker container run -e ACCEPT_FSL_EULA=1 -d -it --privileged \
    --name=graphics-tests -v /dev:/dev -v /tmp:/tmp \
    artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/graphics-tests-imx8:stable-rc
}

teardown_suite() {
    docker container stop graphics-tests
    docker image rm -f $(docker container inspect -f '{{.Image}}' graphics-tests)
    docker container rm graphics-tests
}
