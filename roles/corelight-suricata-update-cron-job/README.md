# Suricata-update-cron-job Ansible Role

- The role will only run Suricata-update and push Suricata rules to enabled Corelight sensors
- This role is designed to be run from a Cron Job to run Suricata-update via Ansible on a daily bases
- All configuration and setup should be performed with the Corelight Suricata-update Ansible Role

## Requirements

- The corelight-suricata-update Role is used to configure Suricata-update

## Role Variables

- The role variables are the same as the corelight-suricata-update role
- For remote cron_job_hosts, all role variables and inventory files are copied to the cron job host by the Suricata-update role

## License

BSD

## Author Information

Corelight, Inc.
