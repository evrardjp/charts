# Charts repo

Example charts repo throught github docs

## How it works

* Point github pages to docs folder (one time thing)
* Run the `update_upstream_charts` and `generate_charts.sh` script
* git add, commit, and push.

## What does generate_charts do?

* For each chart:

  * Ensuring local changes are applied (helm chart repo location and version)
  * helm package <chart>
  * mv <chart>-<version>.tgz docs

* helm repo index docs --url https://evrardjp.github.com/charts
