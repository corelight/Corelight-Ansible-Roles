#!
ansible-playbook -i ../common/inventory.yml ../suricata-update-cron-job.yml --extra-vars '{"target":"all"}' --extra-vars '@../common/secrets.yml'
