#!
ansible-playbook -i ../common/inventory.yml ../suricata-update-config-run.yml --extra-vars '{"target":"all"}' --extra-vars '@../common/secrets.yml'