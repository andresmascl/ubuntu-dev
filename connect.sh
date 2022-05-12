#!/bin/bash

#Get current cer file from inventory file
cert_path=$(cat inventory | grep -Po "(?<==).*\.pem")

#Get Host from inventory file
host=$(cat inventory | grep -Po "(.*)amazonaws\.com")

ssh -i $cert_path -t ubuntu@$host 
