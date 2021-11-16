resource "random_pet" "name" {}

locals {
  machine_name = "${var.owner}-${random_pet.name.id}-dev-machine"
  generated_key_name = "${var.owner}-${random_pet.name.id}-dev-key-pair"
}

resource "aws_instance" "ubuntu-dev-machine" {
  ami = var.ami
  instance_type = var.instance_type
  tags = {
    owner = var.owner
    expiration = var.expiration
    Name = local.machine_name
  }
  key_name = local.generated_key_name
  vpc_security_group_ids = [aws_security_group.main.id]

  # connection {
  #   type        = "ssh"
  #   host        = self.public_ip
  #   user        = "ubuntu"
  #   private_key = file("/home/rahul/Jhooq/keys/aws/aws_key")
  #   timeout     = "4m"
  # }
}

resource "aws_security_group" "main" {
  name = "${local.machine_name}-sg"
  description = "Allow inbound SSH to manage machine"
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
 ingress                = [
   {
     cidr_blocks      = [ "0.0.0.0/0", ]
     description      = ""
     from_port        = 22
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     protocol         = "tcp"
     security_groups  = []
     self             = false
     to_port          = 22
  }
  ]
}

resource "tls_private_key" "dev_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = local.generated_key_name
  public_key = tls_private_key.dev_key.public_key_openssh

  provisioner "local-exec" {    # Generate "terraform-key-pair.pem" in current directory
    command = <<-EOT
      echo '${tls_private_key.dev_key.private_key_pem}' > ./'${local.generated_key_name}'.pem
      chmod 400 ./'${local.generated_key_name}'.pem
    EOT
  }
}

### The Ansible inventory 
resource "local_file" "AnsibleInventory" {
  content = templatefile("inventory.tmpl", {
#      bastion-dns = aws_eip.eip-bastion.public_dns,  
#      bastion-ip = aws_eip.eip-bastion.public_ip,  
#      bastion-id = aws_instance.bastion.id,  
      private-dns = aws_instance.ubuntu-dev-machine.*.public_dns,  
      private-ip = aws_instance.ubuntu-dev-machine.*.public_ip,  
      private-id = aws_instance.ubuntu-dev-machine.*.id 
      }
  )
  filename = "inventory"
}
