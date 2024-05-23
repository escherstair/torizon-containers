#!/bin/bash

re_tag_image() {
    registry=$1
    namespace=$2
    image_name=$3
    old_image_tag=$4
    new_image_tag=$5

    # check if the tag we want to push already exists
    old_image_path="$registry"/"$namespace"/"$image_name":"$old_image_tag"
    new_image_path="$registry"/"$namespace"/"$image_name":"$new_image_tag"

    if regctl image digest "$new_image_path" >/dev/null 2>&1; then
      echo "Found an existing $new_image_path"
      echo "Exiting successfully"
    else
      echo "Tag $new_image_path does not exist"
      echo "Re-tagging from $old_image_path"
      # has a stable-rc image been pushed yet?
      if regctl image digest "$old_image_path" >/dev/null 2>&1; then
        # it has been pushed, re-tag from $old_image_tag to $new_image_tag
        regctl image copy "$old_image_path" "$new_image_path"
      else
        echo "Can't find a $old_image_path to re-tag from"
        exit 1
      fi
    fi
}

if [ $# -ne 2 ]; then
    echo "Usage: $0 <path_to_container_versions_yml> <registry_namespace>"
    exit 1
fi

yaml_file="$1"
registry_namespace="$2"

while IFS=: read -r image_name rest; do
    image_name=$(echo "$image_name" | xargs)

    major=$(yq e ".$image_name.major" "$yaml_file")
    minor=$(yq e ".$image_name.minor" "$yaml_file")
    patch=$(yq e ".$image_name.patch" "$yaml_file")
    append=$(yq e ".$image_name.append" "$yaml_file")

    if [[ "$append" ]]; then
      re_tag_image docker.io "$registry_namespace" "$image_name" "stable-rc" "$major"."$minor"."$patch""$append"
    fi

    re_tag_image docker.io "$registry_namespace" "$image_name" stable-rc "$major"."$minor"."$patch"
    re_tag_image docker.io "$registry_namespace" "$image_name" stable-rc "$major"."$minor"
    re_tag_image docker.io "$registry_namespace" "$image_name" stable-rc "$major"
    date=$(date +%Y%m%d)
    re_tag_image docker.io "$registry_namespace" "$image_name" stable-rc "$major"."$minor"."$patch"-"$date"

    echo "$image_name: $major.$minor.$patch" >> release_notes.md
    echo "" >> release_notes.md
done < <(yq e 'keys | .[]' "$yaml_file")
