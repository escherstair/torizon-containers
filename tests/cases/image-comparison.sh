#!/usr/bin/env bash

image_compare() {
  # Example usage:
  # image_compare image1.png image2.png <threshold>
  if [ "$#" -ne 3 ]; then
    echo "Usage: image_compare image1 image2 threshold"
    exit 1
  fi

  image1="$1"
  image2="$2"
  threshold="$3"

  difference=$(compare -metric AE "$image1" "$image2" null: 2>&1)

  if [ "$difference" -gt "$threshold" ]; then
    echo "Difference below threshold: $difference"
  else
    echo "Difference above threshold: $difference"
  fi
}

function take_screenshot() {
  local container_name="$1"

  docker exec "$container_name" weston-screenshooter
}

function copy_screenshot() {
  local container_name="$1"

  docker cp "${container_name}:/home/torizon/." .
  docker exec "$container_name" sh -c "rm /home/torizon/wayland-screenshot*.png"
  mv wayland-screenshot*.png /home/torizon/screenshot.png
}
