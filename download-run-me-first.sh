#!

sudo mkdir /etc/corelight
cd /etc/corelight
sudo chown $USER.$USER /etc/corelight
cd /etc/corelight
git clone https://github.com/corelight/Corelight-Ansible-Roles.git
cd Corelight-Ansible-Roles/
git checkout 2.0beta
cd scripts/
./initial_ansible_installation_venv.sh
source /etc/corelight-env/bin/activate

# copy or create variable file
# copy or create secrets file
# copy or create inventory
# copy or create vault password file
# edit /etc/ansible/ansible.cfg and uncomment the following line and point to your vault password file.
#  'vault_password_file = /path/to/vault_password_file'
#        Note: If you need a password for sudo, add 'ansible_become_pass: '{{centos7_sudo}}' to the inventory file.  In this example,  add a variable called 'centos7_sudo' to your secrets.yml with the real password.  If you need if for localhost, make sure you also add it to the 'default-localhost.yml' inventory file.



#  ansible-playbook -i ../common/inventory/ ../install-config-all-main-host.yml  --extra-vars '@../common/secrets.yml'
