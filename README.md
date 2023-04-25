# Terraform and Ansible coding exercise

Summary
This code demonstrates Terraform and Ansible functionality to provision a cloud instance,
configure it, deploy a script and config file to the instance and then run the script with
the specified parameters. Some of the highlights of the code:

* Terraform is used to deploy an Ubuntu 20.04 instance in AWS cloud.
* TCP ports 22 and 443 are opened
* A public key is added to the ubuntu user's authorized_keys file to support ssh access
* The public ip address of the instance is output, to be used in subsequent steps
* Ansible is used to copy an installation script and config file to the instance, in a specified directory
* The script requires a unique installation code. This is collected by the ansible script at runtime, as we want to keep sensitive info out of the code repository
* The config file is modified to include the unique token before executing the install script
* Finally, the installation script is executed with the required parameters. Output is logged so we can verify the install

Requirements
* This code should be executed from a UNIX like environment. This was developed/tested on ubuntu 18.04.
* Recent version of terraform (tested with Terraform v1.4.5)
* Recent version of ansible (tested with ansible core 2.14.5)
* A unique token (string) which is provided to the ansible script at runtime
* CLI access to AWS cloud with sufficient privileges to launch and configure instances. In addition, a VPC and a subnet needs to be configured prior to running this code.
* Code could be modified to support other cloud providers
* Instance is provisioned into the default region specified in your AWS config. See AWS docs for details.
* There are some hard-coded values in the main.tf script. These must be changed before running the code in your environment:
** ami (Amazon Machine Image). This must correspond to the region and flavor of linux you with to deploy. The example is ubuntu 20.04 for us-east-2 region
** ssh public key. You will need to generate a key pair, or use an existing key pair appropriate for your environment.

Usage
Clone the repository to your working directory:

git clone git@github.com:girlbandgeek/csg-code-challenge.git

cd to the terraform directory and execute the following command to initialize terraform:

execute the following commands to validate the code and launch the instance. Respond "yes" when prompted. (Terraform plan is optional.)

terraform plan
terraform apply

Once the instance is provisioned, the public IP address is output. Record this for use in the next step.

public_ip = "3.144.194.246"

At this point, the instance is provisioned. It may take a minute for its state to change from "pending" to "running". You can verify in the AWS console if desired. Now we're ready to use ansible to complete the configuration.

cd to the ansible directory

cd ../ansible

You will need to update the inventory.yaml file with the public ip address of the instance which was output from terraform:

'''
csg_instances:
  hosts:
    csg-test:
      ansible_host: 52.15.166.144
'''

Verify the ansible can successfully connect to the instance by executing the following command (respond "yes" when prompted about authenticity of host):

ansible csg_instances -m ping -i inventory.yaml -u ubuntu

csg-test | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}

Execute the following command to run the playbook, and complete the system configuration. You will be prompted for the unique token, which must be entered to complete the installation:

ansible-playbook -i inventory.yaml csg-install-agent.yaml -u ubuntu

The playbook should complete in 20 seconds or so without errors. To verify success, log in to the instance, and check the contents of the "install.log" in the /opt/csg_security_agent folder. It should contain "Agent Installation Succeeded"

'''
ubuntu@ip-172-31-38-171:/opt/csg_security_agent$ cd /opt/csg_security_agent/
ubuntu@ip-172-31-38-171:/opt/csg_security_agent$ ll
total 20
drwxr-xr-x 2 root root 4096 Apr 25 23:37 ./
drwxr-xr-x 3 root root 4096 Apr 25 23:37 ../
-rw-r--r-- 1 root root   29 Apr 25 23:37 install.log
-rwxr-xr-x 1 root root   83 Apr 25 23:37 security_agent_config.conf*
-rwxr-xr-x 1 root root  443 Apr 25 23:37 security_agent_installer.sh*
ubuntu@ip-172-31-38-171:/opt/csg_security_agent$ cat install.log 
Agent Installation Succeeded
'''

Once you have completed the exercise, you will probably want to remove the instance and other configs from AWS or other cloud provider to avoid unnecessary cost. Change directory back to the terraform directory, and execute the following command to remove the instance completely. Respond "yes" when prompted to confirm the command:

terraform destroy
