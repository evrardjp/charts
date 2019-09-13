#!/bin/bash

set -o errexit
set -x

# Upstream source update
git submodule init --update
for folder in openstack-helm-infra openstack-helm; do
    pushd $folder
        git fetch
        git merge origin/master
    popd
done

