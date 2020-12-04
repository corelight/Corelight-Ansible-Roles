#!
ansible-playbook -i ../common/inventory/ ../zkg.yml --extra-vars '{"target":"all"}' --extra-vars '@../common/secrets.yml'
