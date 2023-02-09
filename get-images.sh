#!/bin/bash
set -euxo pipefail

aws ec2 describe-regions --filters Name=opt-in-status,Values=opted-in,opt-in-not-required \
    | jq -r '.Regions[].RegionName' | sort > regions.txt

# Short circuit with just two regions for now.
echo "us-east-1" > regions.txt
echo "us-east-2" >> regions.txt

for REGION in $(cat regions.txt); do
  aws --region=${REGION} ec2 describe-images \
    --filters Name=is-public,Values=true | jq -c > ${REGION}.json
done