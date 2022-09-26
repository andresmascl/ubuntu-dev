#!/bin/bash

. config-vars.sh


terraform init

eval $(maws li "$MAWS_ACCOUNT")

terraform apply -var owner="$AWS_OWNER"

all_arguments=$@

retrieve_credentials=false

echo '========== Local setup... =============='
./local-setup.sh

for i in $@
do
    if [ "$i" == 'deploy-kommander' ]; then

        echo '========== Deploying Kommander... =========='
        ./deploy-komdr.sh

        retrieve_credentials=true
    fi
done

for i in $@
do
    if [ "$i" == 'install-kaptain' ]; then

        echo '========== Deploying Kommander... =========='
        ./deploy-komdr.sh
        
        echo '========== Installing Kaptain... ==========='
        ./install-kapt.sh

        retrieve_credentials=true
    fi
done


# output ssh connection command
cert_path=$(cat inventory | grep -Po "(?<==).*\.pem")
host=$(cat inventory | grep -Po "(.*)amazonaws\.com")

echo "========== SSH command =========="
echo "ssh -i $(pwd)/$cert_path -t ubuntu@$host"

# output kommander and kaptain credentials
if [ "$retrieve_credentials" == true ]; then
    echo '========== Retrieving credentials =========='
    ./retrieve-credentials.sh
fi
