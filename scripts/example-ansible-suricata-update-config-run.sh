#!
ansible-playbook -i ../common/inventory.yml ../suricata-update.yml --extra-vars '{"target":"all"}' --extra-vars '@../common/secrets.yml'
