#!
ansible-playbook -i ../common/inventory/ ../software-sensor-reconfig-all.yml --extra-vars '@../common/secrets.yml'
