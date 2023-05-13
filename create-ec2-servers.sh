#!/bin/bash

set -x
AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=Centos-8-DevOps-Practice" | jq '.Images[].ImageId' | xargs)
SG_NAME="allow-all"
SGID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=${SG_NAME} | jq  '.SecurityGroups[].GroupId' | xargs)
if [ -z "${SGID}" ]; then
  echo "Given Security Group does not exit"
  exit 1
fi

for component in frontend mongodb catalogue cart mysql user payment shipping dispatch redis rabbitmq; do
  COMPONENT="${component}"
  aws ec2 request-spot-instances \
    --instance-count 1 \
    --launch-specification "{\"ImageId\":\"${AMI_ID}\",\"InstanceType\":\"t3.micro\",\"SecurityGroupIds\":[\"${SGID}\"],\"TagSpecifications\":[{\"ResourceType\":\"spot-instances-request\",\"Tags\":[{\"Key\":\"Name\",\"Value\":\"${COMPONENT}\"}]}],\"InstanceMarketOptions\":{\"MarketType\":\"spot\",\"SpotOptions\":{\"SpotInstanceType\":\"persistent\",\"InstanceInterruptionBehavior\":\"stop\"}}}"
done

