# AWS-Example

This repository is an introductory example to Infrastructure as Code (IAC) with AWS, Terraform and Ansible.

The example is the provisioning of an EC2 instance, hosting a simple html through an nginx.

## Prerequisites

### AWS Setup

##### AWS account

In order to get started, you need an [AWS account](https://aws.amazon.com/console/).
You can set a budget (`Services > Billing > Budget > Create Budget`) to make sure you won't have any unpleasant surprises. 
For this tutorial you will need at most a few dollars, so you could set up a budgt for around 10$.

##### IAM User
To be able to build up infrastructure in AWS from your own machine, you need an IAM user.
Go to `Services > IAM > Groups` and create a new group that has the following access rights:
* AmazonEC2FullAccess
* IAMFullAccess
* AmazonS3FullAccess

Now create a new user within this group. Be cautious with your credentials!

On your own machine, create the file `~/.aws/credentials` with that users access key and this structure:

```
[default]
aws_access_key_id=xxxxx
aws_secret_access_key=xxxxx
```

##### Keypair
To connect to a machine that you create in AWS, you need a keypair, with the private key on your machine and the public key in AWS.
You can create a new keypair on your own machine by running `ssh-keygen -t rsa` in a shell. 

Note the path to the private key and replace the terraform variable `privateKeyPath` in `modules/Infrastructure/main.tf` with your own.

Click on Key Pairs in your [EC2 Dashboard](https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2) and import your public key.


### Local Machine Setup

Install the following on your machine (versions I used are indicated in brackets):
```
terraform     (0.10.5)
ansible       (2.3.2.0)
python2       (2.7.13)
pip2          (9.0.1)
pip2 install -U boto six ansible
```

## Running the Example Code

#### Setup AWS Bucket for Terraform State

Navigate to `modules/TerraformState` and run `terraform init`, then `terraform apply`.
This will create an AWS S3 bucket where you can remotely store your terraform state. This makes it easiest to work in a team.
You will also see a new `.terraform` folder in this directory which holds amongst other things the terraform state for your newly created S3 bucket.
Navigate to your [S3 bucket](https://s3.console.aws.amazon.com/s3/home?region=us-east-2#) to have a look.

#### Provision your Infrastructure

Navigate to `modules/Infrastructure` and run `terraform init`.
This will create the terraform state in the above mentioned S3 bucket.

Now you can run `terraform apply` which will create a new security group and an EC2 instance.

##### Security Group
The security group is configured to allow ssh and http traffic to the instance and anything away from the instance.

##### EC2 Instance
The EC2 instance is setup with an ubuntu 16.04 as amazon machine image (ami).

The remote provisioner ensures that an ssh connection is established and python is installed; both are prerequisites for ansible.

The local provisioner runs the ansible playbook that you can find in `modules/Provision`, which installs and starts an nginx webserver and hosts a simple html.

#### Checking the Result

In the [EC2 Dashboard](https://us-east-2.console.aws.amazon.com/ec2/v2/home?region=us-east-2) you should now see 1 Running Instance and 2 Security Groups (yours in addition to the default VPC).

Clicking on `Running Instances` will list all EC2 instances. Copy the public IP from the rightmost column into a new browser tab and look at your new website!

#### Playground

There is a couple of things you could change now to get more comfortable with your infrastructure.

* Change the instance type to a smaller one e.g. t2.micro, or bigger one e.g. t2.large.
* Add more instances by increasing the count variable.
* Create a load balancer to handle all these instances.
* Create a custom network to your infrastructure and add your instance to a subnet in that new network.
* Add additional tasks to the ansible playbook to fit your needs.

#### Clean Up

Run `terraform destroy` in `modules/Infrastructure` to clean up your infrastructure and to avoid unneccessary cost.

To get rid of S3 bucket as well, set the lifecycle parameter `prevent_destroy = false` and run `terraform destroy` in `modules/TerraformState`.
