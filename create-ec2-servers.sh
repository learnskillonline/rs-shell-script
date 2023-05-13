#!/bin/bash

set -x
AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=Centos-8-DevOps-Practice" | jq -r '.Images[].ImageId')
SG_NAME="allow-all"
SGID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=${SG_NAME} | jq -r '.SecurityGroups[].GroupId')

if [ -z "${SGID}" ]; then
  echo "Given Security Group does not exist"
  exit 1
fi

for component in frontend mongodb catalogue cart mysql user payment shipping dispatch redis rabbitmq; do
  COMPONENT="${component}"
  aws ec2 request-spot-instances \
    --instance-count 1 \
    --image-id "${AMI_ID}" \
    --instance-type t3.micro \
    --instance-market-option "MarketType=spot,SpotOptions={InstanceInterruptionBehavior=stop,SpotInstanceType=persistent}" \
    --security-group-ids "${SGID}" \
    --tag-specifications "ResourceType=spot-instances-request,Tags=[{Key=Name,Value=${COMPONENT}}]"
done


