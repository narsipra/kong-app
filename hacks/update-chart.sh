#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

LAST_SYNC_COMMIT=$(git log -n1 --grep '^\[upstream-sync\]' --pretty='format:%h' helm/)
TMPDIR=$(mktemp -d)

UPSTREAM_ZIP_URL=${UPSTREAM_ZIP_URL:-"https://github.com/Kong/charts/archive/main.zip"}
KEEP_TMPDIR=${KEEP_TMPDIR:-''}

clean_on_exit() {
  [[ -z "${KEEP_TMPDIR}" ]] && rm -rf ${TMPDIR}
}

if [ -z "${LAST_SYNC_COMMIT}" ]
then
  echo "Didn't find a commit with [upstream-sync]"
  exit 1
fi

curl -sL -o ${TMPDIR}/main.zip ${UPSTREAM_ZIP_URL}
unzip -d ${TMPDIR}/ ${TMPDIR}/main.zip charts-main/charts/kong/*

UPSTREAM_VERSION=$(cat ${TMPDIR}/charts-main/charts/kong/Chart.yaml | awk '/^version:/ { print $2 }')

cp -a ${TMPDIR}/charts-main/charts/kong/* helm/kong-app/

git add helm/kong-app/
git commit -m "[upstream-sync] Version ${UPSTREAM_VERSION}"
git rev-list --no-merges --reverse ${LAST_SYNC_COMMIT}..HEAD~1 -- helm/kong-app/ | git cherry-pick -X theirs -n --stdin
git commit -m "Cherry picked commits ${LAST_SYNC_COMMIT}..HEAD~1"

trap clean_on_exit EXIT
