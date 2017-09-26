variable "region" {
    default = "us-east-2"
}

variable "privateKeyPath" {
    default = "/Users/Agnes/Projects/Playground/aws_example"
}

provider "aws" {
    region = "${var.region}"
}

terraform {
    backend "s3" {
        bucket = "aws-example-terraform-state"
        key = "terraform.tfstate"
        region = "us-east-2"
    }
}

resource "aws_security_group" "example_allow_ssh" {
    name = "example_allow_ssh"

    ingress {
        from_port = 22
        protocol = "tcp"
        to_port = 22
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        protocol = "tcp"
        to_port = 80
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        protocol = "-1"
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "example_instance" {
    ami = "ami-dbbd9dbe"
    instance_type = "t2.medium"
    vpc_security_group_ids = ["${aws_security_group.example_allow_ssh.id}"]
    count = 1

    key_name = "aws_example"
    connection {
        user = "ubuntu"
        private_key = "${file("${var.privateKeyPath}")}"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo apt -qqy update",
            "sudo apt install -qqy python-minimal"
        ]
    }

    provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../Provision/ec2.py -u ubuntu --private-key ${var.privateKeyPath} ../Provision/playbook.yml"
    }
}