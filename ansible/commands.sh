# Run commands in EC2 instance sets
ansible qa -a "python --version"
ansible groupofgroups -a "python --version"
ansible devsubset -a "python --version"

# Execute playbooks
ansible-playbook playbooks/01-ping.yml
ansible-playbook playbooks/02-shell.yml
ansible-playbook playbooks/03-variables.yml
ansible-playbook playbooks/03-variables.yml -e variable1=CLI_Value
ansible-playbook playbooks/04-facts.yml
ansible-playbook playbooks/05-install-apache.yml

# Multiple playbooks
ansible-playbook playbooks/06-multiple-playbooks.yml
ansible-playbook playbooks/06-multiple-playbooks.yml --list-tasks
ansible-playbook playbooks/06-multiple-playbooks.yml --list-hosts

# Runs only in qa set
ansible-playbook -l qa playbooks/01-ping.yml
