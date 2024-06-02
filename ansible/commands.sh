# Run commands in EC2 instance sets
ansible qa -a "python --version"
ansible groupofgroups -a "python --version"
ansible devsubset -a "python --version"

# Execute playbooks
ansible-playbook playbooks/01-ping.yml
ansible-playbook playbooks/02-shell.yml