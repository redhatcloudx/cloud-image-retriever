#!/bin/bash
set -euxo pipefail

aws ec2 describe-regions --filters Name=opt-in-status,Values=opted-in,opt-in-not-required \
    | jq -r '.Regions[].RegionName' | sort > regions.txt

for REGION in $(cat regions.txt); do
  sem -j 10 "aws --region=${REGION} ec2 describe-images --filters Name=is-public,Values=true | jq -c .Images > ${REGION}.json"
done

sem --wait

for REGION in $(cat regions.txt); do
  mkdir -p aws/${REGION}/
  cp -a ${REGION}.json aws/${REGION}/index.json
done

s3cmd sync --acl-public --delete-removed --guess-mime-type --no-mime-magic $(pwd)/aws/ s3://cloudx-json-bucket/raw/aws/
