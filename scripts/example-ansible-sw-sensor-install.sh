#!
ansible-playbook -i ../common/inventory.yml ../sw-sensor-install.yml --extra-vars '{"target":"all"}' --extra-vars '@../common/secrets.yml'