#!/bin/bash

set -x
set -e

# Vendor in the latest upstream charts
git subtree pull --prefix openstack-helm-infra/ https://github.com/openstack/openstack-helm-infra.git master --squash -m "Squash merged OSH-infra from master upstream"
git subtree pull --prefix openstack-helm/ https://github.com/openstack/openstack-helm.git master --squash --squash -m "Squash merged OSH from master upstream"

# Determine next version number
version=$(git rev-list --count --no-merges HEAD)

main_folder=$(pwd)

for chartfolder in openstack-helm-infra/helm-toolkit $(dirname $(find openstack-helm openstack-helm-infra -maxdepth 2 -mindepth 2 -type f -name Chart.yaml)); do
    pushd $chartfolder
        helmchartname=$(basename ${chartfolder})
        sed -i "s/version: .*/version: 1.0.${version}/" Chart.yaml
        # Some charts don't have requirements like lockdown or htk
        # The only requirement is always htk. Easy.
        if [[ -f requirements.yaml ]] && [[ "${helmchartname}" != "helm-toolkit" ]]; then
            mkdir -p charts/helm-toolkit
            cp -r ${main_folder}/openstack-helm-infra/helm-toolkit/* charts/helm-toolkit/
            sed -i 's#http://localhost:8879#https://evrardjp.github.com#' requirements.yaml
            sed -i "s#version: .*#version: 1.0.${version}#" requirements.yaml
        fi
        if [[ -d values_overrides ]]; then
            python ${main_folder}/yaml-tools.py merge -i values.yaml values_overrides/*suse*.yaml -o suse-values.yaml
        fi
    popd
    pushd $(dirname $chartfolder)
        helm package ${helmchartname}
        mv ${helmchartname}-1.0.${version}.tgz ${main_folder}/docs/
    popd
done
helm repo index docs --url https://evrardjp.github.com/charts

echo "You can now merge the changes with:
git add .
git commit -m \"New release 1.0.${version}\"
git push"
