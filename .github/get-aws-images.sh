#!/bin/bash
set -euxo pipefail

aws ec2 describe-regions --filters Name=opt-in-status,Values=opted-in,opt-in-not-required \
    | jq -r '.Regions[].RegionName' | sort > regions.txt

for REGION in $(cat regions.txt); do
  sem -j 5 "aws --region=${REGION} ec2 describe-images --filters Name=is-public,Values=true > ${REGION}-raw.json"
done

sem --wait

for REGION in $(cat regions.txt); do
  cat ${REGION}-raw.json | jq .Images | jq --arg newval "$REGION" '.[] += { Region: $newval }' > aws-${REGION}.json
done

# Merge all of the JSON files into one.
jq -c -s add aws-*.json > index.json
