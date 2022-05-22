# Create an ubuntu EC2 instance for dev in AWS 

## Prerequisites 
Requires Terraform v0.13.7. Use tfenv[https://github.com/tfutils/tfenv] for installation.

## Creation
Edit the `terraform.tfvars` file and adjust the instance_type values.

Create a [github certificate](https://docs.github.com/en/enterprise-server@3.2/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

Edit the `config-vars.sh` file and complete with your info:
- `GITHUB_CERT_PATH=~/.ssh/<name_of_my_cert>`  # << no `.pub` here
- `GITHUB_REPO=git@github.com:<path-to-my-repo.git>`
- ...etc.

Put the `config-vars.sh` file on your desktop

### 5 commands:
``` shell
# installing dependencies and cloning repository
./main.sh

# the above plus deploying a kommander cluster
./main.sh deploy-kommander

# the above plus installing kaptain
./main.sh install-kaptain

# retrieve credentials for the SSH connection, Kommander UI, and Kaptain UI
./retrieve-credentials.sh

# create an SSH connection
./connect.sh
```

# Expert level stuff:
## Multiple Workspaces
You can create multiple machines this way:

```
$ terraform workspace new dev-machine2
$ terraform init
$ terraform apply
```
