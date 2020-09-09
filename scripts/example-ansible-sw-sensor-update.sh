#!
ansible-playbook -i ../common/inventory.yml ../sw-sensor-update.yml --extra-vars '{"target":"all"}' --extra-vars '@../common/secrets.yml'