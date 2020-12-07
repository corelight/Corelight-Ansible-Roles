#!
ansible-playbook -i ../common/inventory/ ../suricata-update-run-host.yml --extra-vars '@../common/secrets.yml'
