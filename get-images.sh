#!/bin/bash
set -euxo pipefail

aws ec2 describe-regions --filters Name=opt-in-status,Values=opted-in,opt-in-not-required \
    | jq -r '.Regions[].RegionName' | sort > regions.txt

for REGION in $(cat regions.txt); do
  sem -j 10 "aws --region=${REGION} ec2 describe-images \
    --filters Name=is-public,Values=true | jq -c > ${REGION}.json"
done

sem --wait

zstd -vv -T0 -19 --auto-threads=logical --rm *.json