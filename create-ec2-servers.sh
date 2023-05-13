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
  aws ec2 run-instances \
    --image-id ${AMI_ID} \
    --tag-specifications "ResourceType=spot-instances-request,Tags=[{Key=Name,Value=${COMPONENT}}]" \
    --instance-type t3.micro \
    --instance-market-options "MarketType=spot,SpotOptions={SpotInstanceType=persistent,InstanceInterruptionBehavior=stop}" \
    --security-group-ids "${SGID}"
done


