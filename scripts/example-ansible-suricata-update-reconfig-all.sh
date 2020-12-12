#!
ansible-playbook -i ../common/inventory/ ../suricata-update-reconfig-all.yml  --extra-vars '@../common/secrets.yml'
