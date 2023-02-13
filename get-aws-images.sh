#!/bin/bash
set -euxo pipefail

aws ec2 describe-regions --filters Name=opt-in-status,Values=opted-in,opt-in-not-required \
    | jq -r '.Regions[].RegionName' | sort > regions.txt

# Short circuit the regions until we know this is working correctly.
echo "us-east-1" > regions.txt
echo "us-east-2" >> regions.txt

for REGION in $(cat regions.txt); do
  sem -j 10 "aws --region=${REGION} ec2 describe-images --filters Name=is-public,Values=true | jq -c > ${REGION}.json"
  mkdir -vp aws/${REGION}/
  cp ${REGION}.json aws/${REGION}/index.json
done

sem --wait

s3cmd sync --acl-public --delete-removed --guess-mime-type --no-mime-magic --rexclude '.*' aws/ s3://cloudx-testing/aws/