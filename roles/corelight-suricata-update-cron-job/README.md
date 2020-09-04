# Suricata-update-cron-job Ansible Role

The role will only run Suricata-update and push Suricata rules to enabled Corelight sensors.  It is used to run Suricata-update via Ansible and a Cron Job on a daily bases.  All configuration and setup should be performed with the Corelight Suricata-update Ansible Role.

## Requirements

- The corelight-suricata-update Role is used to configure Suricata-update

## Role Variables

- All role variables and inventory files are copied to the cron job host by the Suricata-update role.

## License

BSD

## Author Information

Corelight, Inc.
