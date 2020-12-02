#!/usr/bin/env bash

# This script should be used to pull in updates from upstream.
# Use it as a first step for updating from upstream.
#
# General outline:
#
# - Create a branch
# - Execute `./hacks/update-chart.sh`
# - Look at the commits created by the script.
#   - First one contains all upstream changes from our last commit with message `[upstream-sync] Version XXX`
#   - Second one re-applies all changes which happened in the mean time in our repository. Use this as a starting point for reverting changes overwritten by the second commit
# - `git revert --no-commit HEAD` will revert changes from the second commit.
# - Unstage everything that you don't want to be reverted
# - Commit, push & create PR

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
