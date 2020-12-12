#!
ansible-playbook -i ../common/inventory/ ../install-config-all-software-sensor.yml  --extra-vars '@../common/secrets.yml'
