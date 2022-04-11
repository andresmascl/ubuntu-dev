# Create an ubuntu EC2 instance for dev in AWS 

## Prerequisites 
Requires Terraform v0.13.7. Use (tfenv)[https://github.com/tfutils/tfenv] for installation.

## Creation
Edit the `terraform.tfvars` file and adjust the instance_type values.

To install apply the terraform files. This will generate a key pair and create the machine.

Create a [github certificate](https://docs.github.com/en/enterprise-server@3.2/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

### Set path for the GitHub private key and repo to clone

``` shell
export GITHUB_CERT_PATH=~/.ssh/<name_of_my_cert>  # no .pub here
export GITHUB_REPO=git@github.com:<path-to-my-repo.git>
```

### Initiate Terraform
``` shell
terraform init
```

### Make sure you have logged in AWS recently
``` shell
eval $(maws li <somelongnumber-Someaws_Accountname>)
```

### Start the dev machine
``` shell
terraform apply -var owner="$(whoami)"
```

The command will output the public dns of the machine as well as an SSH connection string. It is recommended to use tmux to prevent commands from failing due to connection.

### To connect with ssh

``` shell
./connect.sh
```

### Set up repo and dev env

``` shell
# Run script to checkout dev repo and set env vars
./local-setup.sh
```

### Deploy the default version of a cluster
``` shell
# You can specify EXPIRATION_TIME providing an integer.  Default is 12 hours
./deploy-kappy.sh
```

### Obtain credentials after deployment:
``` shell
./retrieve-credentials.sh
```


## Multiple Workspaces
You can create multiple machines this way:

```
$ terraform workspace new dev-machine2
$ terraform init
$ terraform apply
```
