#!/bin/bash

# please move config-vars.sh to your desktop or modify this route:
. ~/Desktop/config-vars.sh

all_arguments=$@

terraform init

eval $(maws li "$MAWS_ACCOUNT")

terraform apply -var owner="$AWS_OWNER"

#Get current cer file from inventory file
cert_path=$(cat inventory | grep -Po "(?<==).*\.pem")

#Get Host from inventory file
host=$(cat inventory | grep -Po "(.*)amazonaws\.com")

all_arguments=$@

retrieve_credentials=false
for i in $@
do
    if [ "$i" == 'deploy-komdr' ]; then
        echo '========== Local setup =============='
        ./local-setup.sh

        echo '========== Deploying Komdr =========='
        ./deploy-komdr.sh
        retrieve_credentials=true
    fi
done

for i in $@
do
    if [ "$i" == 'deploy-kapt' ]; then
        echo '========== Deploying Kapt ==========='
        ./deploy-kapt.sh
        retrieve_credentials=true
    fi
done

if [ "$retrieve_credentials" == true ]; then
    echo '========== Retrieving credentials =========='
    ./retrieve-credentials.sh
fi
