# Corelight-Ansible-Roles

**Caution:** Before you run this version, if you are upgrading, some variable names and locations have changed

To get started, simply run this command:

```source <( curl https://raw.githubusercontent.com/corelight/Corelight-Ansible-Roles/2.0beta/download-run-me-first.sh)```

This product includes GeoLite2 data created by MaxMind, available from <https://www.maxmind.com>.
You can sign up for free and get a license key from <https://www.maxmind.com/en/geolite2/signup>

Corelight-Ansible-Roles are a collection of roles and playbooks to install, configure, run and manage a variety of Corelight ans Zeek solutions.  To include:

- Rules Management for Corelight-Suricata, including Fleet managed sensors (Suricata integration into a Corelight sensor)
- Creates and manages cron jobs for Suricata-update
- Input Framework Management for all Corelight sensors, including Fleet managed sensors
- Intel Framework Management for all Corelight sensors (coming soon)
- Zeek Package Management for all Corelight sensors (currently only creates a bundle for Fleet managed sensors)
- Full management of Corelight Software sensors (install, configure and maintain)
- Automatically installs or upgrades and configures all dependent applications in Python3 virtual environments.
  - Global installations include:
    - Python3
    - Python3-venv
    - git
  - Isolated python venv installations include:
    - Python3-pip
    - Ansible (on a remote host)
    - zkg (Zeek Package Manager)
    - Corelight-client
    - Suricata-update
    - Corelight Software Sensor

## Full Documentation coming soon
