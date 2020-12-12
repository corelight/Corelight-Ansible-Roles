#!
ansible-playbook -i ../common/inventory/ ../suricata-update-reconfig-select.yml  --extra-vars '@../common/secrets.yml'
# To add the name of the host to the command line so it won't prompt, add the following:
# --extra-vars '{"target":"name of host"}'
# save modified scripts with 'ansible-' at the beginning so they are not overwritten with 'git pull'
