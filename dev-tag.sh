#!/bin/bash
set -e

# Verify tag arg
if [ -z "$1" ]; then
    echo usage: $0 TAG
    exit 1
fi
if [ -n "$(git tag -l $1)" ]; then
    echo $1 tag exists run
    echo "    " git tag -d $1
    exit 1
fi

set -v

# Create a valid submodule semver tag for ./hack/update-codegen.sh
while true; do
    TAG=$(git describe --tags HEAD)
    if ! git tag -d "$TAG" 2>/dev/null; then
        break
    fi
done
git tag -d v0.0.0 2>/dev/null || true
git tag v0.0.0
trap "git tag -d v0.0.0 >/dev/null 2>&1" exit

git tag $1
for i in staging/src/k8s.io/*; do
    git tag -d $i/$1 2>/dev/null || true
    git tag $i/$1
done

# Show git push commands
set +v

echo "--------------------------"
for i in staging/src/k8s.io/*; do
    echo git push origin $i/$1
done
echo git push origin $1
