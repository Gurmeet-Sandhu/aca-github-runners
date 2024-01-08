#!/bin/bash
ORG=$ORG
PAT=$PAT
LABELS=$LABELS

RUNNER_NAME="RUNNER-$(hostname)"
TOKEN=$(curl -sX POST -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${PAT}" https://api.github.com/orgs/${ORG}/actions/runners/registration-token | jq .token --raw-output)
cd /home/runner/actions-runner
./config.sh --unattended --url https://github.com/${ORG} --token ${TOKEN} --name ${RUNNER_NAME} --labels ${LABELS} --runnergroup aca-runners --ephemeral --disableupdate

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --token ${TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!