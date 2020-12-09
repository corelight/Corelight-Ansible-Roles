#!
ansible-playbook -i ../common/inventory/ ../suricata-update-reconfig-host.yml  --extra-vars '@../common/secrets.yml'
