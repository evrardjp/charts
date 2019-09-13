#!/bin/bash

set -x

# Determine current version
version=$(git rev-list --count --no-merges HEAD)
main_folder=$(pwd)

for chartfolder in openstack-helm-infra/helm-toolkit $(find openstack-helm openstack-helm-infra -maxdepth 1 -mindepth 1 -type d | grep -v -e helm-toolkit -e tools -e doc -e releasenotes -e zuul -e playbooks -e roles -e test); do
    pushd $chartfolder
        helmchartname=$(basename ${chartfolder})
        if [[ "$helmchartname" != "helm-toolkit" ]]; then
            if [[ ! -d charts/helm-toolkit ]]; then
                mkdir -p charts/helm-toolkit
            fi
            cp -r ${main_folder}/openstack-helm-infra/helm-toolkit/* charts/helm-toolkit/
            sed -i 's/localhost:8879/evrardjp.github.com/' requirements.yaml
            sed -i "s/version: 0.1.0/version: 1.0.${version}/" requirements.yaml
        fi
        sed -i "s/version: 0.1.0/version: 1.0.${version}/" Chart.yaml
        if [[ -d values_overrides ]]; then
            cp values_overrides/*suse* ./
        fi
    popd
    pushd $(dirname $chartfolder)
        helm package ${helmchartname}
        mv ${helmchartname}-1.0.${version}.tgz ${main_folder}/docs/
    popd
done
helm repo index docs --url https://evrardjp.github.com/charts

# Cleanup the upstream repos.
for folder in openstack-helm-infra openstack-helm; do
    pushd $folder
        git clean -fd
        git checkout -- .
    popd
done
