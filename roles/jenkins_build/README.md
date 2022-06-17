# Jenkins Build

Jenkins Server Provisioning with Ansible Role. Checkout the [main.yml](./tasks/main.yml) file for steps to use this role.

## :rocket: Technologies

The following tools were used in this project:

- [Terraform](https://www.terraform.io/)
- [Ansible](https://www.ansible.com/)

## :checkered_flag: Starting

```bash
# Clone the project
git clone https://github.com/devenes/jenkins-server-ansible-role.git

# Access the project folder
cd jenkins-server-ansible-role

# Edit your backend, variables and initialize terraform
terraform init

# Run the project with terraform
terraform apply -auto-approve
```

## 🚀 Usage

- Initialize Ansible role with using Ansible Galaxy

```bash
ansible-galaxy init roles/jenkins_build
```

- Encrypt the Jenkins server login password with using Ansible Vault

```bash
ansible-vault encrypt secret.yml
```

- Run the project playbook with Ansible

```bash
ansible-playbook play.yml --ask-vault-pass
```

- Write the Jenkins job to the xml file with using Ansible as management tool

```bash
ansible all -b -m shell -a "sudo java -jar /root/jenkins-cli.jar -s http://localhost:8080/ -auth @/root/jenkinsauth get-job "job_template" > /root/job.xml"
```

- Get the Jenkins job

```bash
ansible all -b -m shell -a "cat /root/job.xml"
```

## 💄 Groovy Script

Write the Groovy script to create the login credentials for the Jenkins server with using Ansible as automation tool.

```groovy
import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

println "--> creating local user 'admin'"

def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount('admin', '{{ admin_pass }}')
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)
instance.save()
```

## :memo: License

This project is under license from Apache License 2.0.

## Author Information

Made with :heart: by <a href="https://github.com/devenes" target="_blank">devenes</a>
