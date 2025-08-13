#!/bin/bash

#k8s-deployment-rollout-status.sh

sleep 20s

echo "Context: $(kubectl config current-context)"

echo ${deploymentName}

if [[ $(kubectl -n default rollout status deploy ${deploymentName} --timeout 5s) != *"successfully rolled out"* ]]; 
then     
	echo "Deployment ${deploymentName} Rollout has Failed"
    kubectl -n default rollout undo deploy ${deploymentName}
    exit 1;
else
	echo "Deployment ${deploymentName} Rollout is Success"
fi