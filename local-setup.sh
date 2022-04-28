#!/bin/bash

# Connects to the newly created EC2 machine and clones script from github

# please move config-vars.sh to your desktop or modify this route:
. ~/Desktop/config-vars.sh

github_cert_path=${GITHUB_CERT_PATH:-~/.ssh/linux_cloud_dev_ed25519}
github_cert_file=$(basename $github_cert_path)
github_repo=${GITHUB_REPO:-git@github.com:mesosphere/kaptain.git}
git_user=${GIT_USER}
git_email=${GIT_EMAIL}

yellow='\033[1;33m'
nc='\033[0m'

if [ -z "${git_user}"] || [-z "${git_email}"]; then
    echo -e "\n${yellow}Please export GIT_USER and GIT_EMAIL to configure in remote machine${nc}\n"
    exit 1
else
    echo -e "\nGIT_USER=${git_user}, GIT_EMAIL=${git_email}\n"
fi

if [ -n "$1" ]; then
    cert_path = $1
else
    #Get current cer file from inventory file
    cert_path=$(cat inventory | grep -Po "(?<==).*\.pem")
fi

#Get Host from inventory file
host=$(cat inventory | grep -Po "(.*)amazonaws\.com")

echo -e "\nHost: ${host}, Key file: ${cert_path}\n"

echo Write hostname file...
echo $host > hostname

echo Copy private key ${github_cert_path} to host for GitHub...
scp -i $cert_path ${github_cert_path} ubuntu@$host:~/.ssh/

# Add Public Key to known_hosts
ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=10 -i $cert_path ubuntu@$host "ssh-keyscan github.com >> ~/.ssh/known_hosts"

echo Checkout the repo

# this next line is ugly but it works, so I will leave it as it is for now
ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=10 -i $cert_path ubuntu@$host 'eval "$(ssh-agent -s)" && ssh-add ~/.ssh/'$github_cert_file' && git clone --recursive '$github_repo

ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=10 -i $cert_path ubuntu@$host "sudo mv ~/kubectl //usr/local/bin/"

ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=10 -i $cert_path ubuntu@$host "git config --global user.name $git_user && git config --global user.email $git_email"