#!/bin/bash

# Parse flags
bump_minor=false
bump_major=false

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --bump-minor)
            bump_minor=true
            shift
            ;;
        --bump-major)
            bump_major=true
            shift
            ;;
    esac
done

if [ "$bump_minor" = true ] && [ "$bump_major" = true ]; then
    echo "--bump-minor and --bump-major are mutually exclusive"
    exit 1
fi

# Read version from file
VERSION_FILE="version"

current_version=$(cat "$VERSION_FILE")

IFS='.' read -r major minor patch <<< "$current_version"

# bump version
if $bump_minor; then
    minor=$((minor + 1))
    patch="0"
elif $bump_major; then
    major=$((major + 1))
    minor="0"
    patch="0"
else
    patch=$((patch + 1))
fi

new_version="$major.$minor.$patch"

echo "$new_version" > "$VERSION_FILE"

# execute build and pushes
echo -e "\nBuilding Application\n"
go build -o ./build/automation-api
if [ $? -ne 0 ]; then
    echo "Go build failed"
    exit 1
fi

echo -e "\nBuilding docker image for new version\n"
docker build -t iamsamd/automation-api:"$new_version" .
if [ $? -ne 0 ]; then
    echo "Docker build failed"
    exit 1
fi

echo -e "\nPushing image version $new_version\n"
docker push iamsamd/automation-api:"$new_version"
if [ $? -ne 0 ]; then
    echo "Docker push for "$new_version" failed"
    exit 1
fi

echo -e "\nTagging image with latest\n"
docker tag iamsamd/automation-api:"$new_version" iamsamd/automation-api:latest
if [ $? -ne 0 ]; then
    echo "Docker tag for latest failed"
    exit 1
fi

echo -e "\nPushing latest image tag\n"
docker push iamsamd/automation-api:latest
if [ $? -ne 0 ]; then
    echo "Docker push for latest failed"
    exit 1
fi

echo -e "\nBuild and push successful\n"