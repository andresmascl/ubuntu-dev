#!/bin/bash

# please move config-vars.sh to your desktop or modify this route:
. ~/Desktop/config-vars.sh

host=$(cat inventory | grep -Po "(.*)amazonaws\.com")  # Get Host from inventory file
cert_path=$(cat inventory | grep -Po "(?<==).*\.pem")  # Get current cer file from inventory file

yellow='\033[1;33m'
nc='\033[0m'

if [ -z "$MAWS_ACCOUNT" ]; then
    read -p "Please enter an AWS account to continue..."$'\n' MAWS_ACCOUNT
fi

echo "
    Host: ${host}
    Key file: ${cert_path}
    "

# ==================================== Obtain AWS Credentials ========================================== #
eval $(maws li "$MAWS_ACCOUNT")


# ==================================== Deploy Cluster ============================================= #
ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=50 -i $cert_path -t ubuntu@$host << HEREDOC
    cd ~/kaptain

    sudo usermod -aG docker ubuntu
    newgrp docker

    export KUBECONFIG=\$(find ~/kaptain -maxdepth 1 -name 'kaptain-*.conf' | awk -F/ '{ print }')
    
    make install
HEREDOC

exit 0