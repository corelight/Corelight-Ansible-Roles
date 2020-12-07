#!
ansible-playbook -i ../common/inventory.yml ../corelight.yml --extra-vars '{"target":"all"}' --extra-vars '@../common/secrets.yml'
