terraform {
  backend "local" {
    path = "/var/lib/jenkins/terraform/workspace/terraform.tfstate"
  }

}

provider "aws" {
  region = "eu-west-1"
  
}

resource "aws_instance" "backend" {
  ami                    = "ami-0713f98de93617bb4"
  instance_type          = "t2.micro"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${var.sg-id}"]

}

resource "null_resource" "remote-exec-1" {
    connection {
    user        = "ec2-user"
    type        = "ssh"
    private_key = "${file(var.pvt_key)}"
    host        = "${aws_instance.backend.public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
    ]
  }
}

resource "null_resource" "ansible-main" {
provisioner "local-exec" {
  command = <<EOT
        sleep 100;
        > jenkins-ci.ini;
        echo "[jenkins-ci]"| tee -a jenkins-ci.ini;
        export ANSIBLE_HOST_KEY_CHECKING=False;
        echo "${aws_instance.backend.public_ip}" | tee -a jenkins-ci.ini;
        ansible-playbook  -i jenkins-ci.ini -u ec2-user --key ${var.pvt_key} ../Ansible/web-playbook.yaml -v    
    EOT
}
}
