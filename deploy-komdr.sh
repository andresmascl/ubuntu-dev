#!/bin/bash

# please move config-vars.sh to your desktop or modify this route:
. ~/Desktop/config-vars.sh

# check for AWS_EXPIRATION, and GPU_ENABLED variables
aws_expiration=${AWS_EXPIRATION:-10h}
gpu_enabled=${GPU_ENABLED:-false}
host=$(cat inventory | grep -Po "(.*)amazonaws\.com")  # Get Host from inventory file
cert_path=$(cat inventory | grep -Po "(?<==).*\.pem")  # Get current cer file from inventory file

yellow='\033[1;33m'
nc='\033[0m'

if [ -z "$MAWS_ACCOUNT" ]; then
    read -p "Please enter an AWS account to continue..."$'\n' MAWS_ACCOUNT
fi

echo "
    AWS owner: ${AWS_OWNER}
    AWS expiration: ${aws_expiration}
    AWS account: ${MAWS_ACCOUNT}
    GPU enabled: ${gpu_enabled}
    Host: ${host}
    Key file: ${cert_path}
    "

# ==================================== Obtain AWS Credentials ========================================== #
eval $(maws li "$MAWS_ACCOUNT")

ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=50 -i $cert_path ubuntu@$host << EOF    
    cd ~/kaptain

    sudo usermod -aG docker ubuntu
    newgrp docker

    make clean-all

    ~/kaptain/tools/dkp/dkp.sh delete bootstrap
    
    export AWS_EXPIRATION=$aws_expiration 
    export AWS_OWNER="$AWS_OWNER"    
    
    unset KUBECONFIG
    
    echo "running make cluster-create kommander -install"
    make cluster-create kommander-install GPU_ENABLED=false
EOF

exit 0