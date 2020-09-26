#!
ansible-playbook -i ../common/inventory.yml ../zkg.yml --extra-vars '{"target":"all"}' --extra-vars '@../common/secrets.yml'