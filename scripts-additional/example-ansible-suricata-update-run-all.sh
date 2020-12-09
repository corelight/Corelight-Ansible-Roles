#!
ansible-playbook -i ../common/inventory/ ../suricata-update-run-all.yml --extra-vars '@../common/secrets.yml'
