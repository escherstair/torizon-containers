image="artifactory-horw.int.toradex.com/dockerhub-proxy-horw/torizon/graphics-tests-am62:stable-rc"
container="graphics-tests"

setup_suite() {

    docker container stop ${container} || true
    docker container rm ${container} || true

    remove-docker-image-if-outdated.sh ${image}

    docker container run -d -it \
            --name=${container} -v /dev:/dev --device-cgroup-rule="c 4:* rmw"  \
            --device-cgroup-rule="c 13:* rmw" --device-cgroup-rule="c 199:* rmw" \
            --device-cgroup-rule="c 226:* rmw" \
            ${image}
}

teardown_suite() {
    docker container stop ${container}

    if [ "$RM_ON_TEARDOWN" = "true" ]; then
        docker image rm -f $(docker container inspect -f '{{.Image}}' ${container})
    else
        echo "Skipping Docker image removal due to RM_ON_TEARDOWN environment variable."
    fi

    docker container rm ${container}

}
