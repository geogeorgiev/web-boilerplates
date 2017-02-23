# ANSILBE USE

## Connecting
Make sure the 'hosts' file has the right ip/domain and user for guest machine. The result may look like this:
	[vagrant]
	192.168.10.20 ansible_ssh_user=vagrant 

Push public keys in the file ~/.ssh/authorized_keys file on the guest. If the home dir is encrypted log once and provide the pass. Then from another command window you will not need to provide the password. 
Auth can be done alternatively with --ask-sudo-pass with ansible-playbook command (see next).

## Run playbook (most options listed, but not always needed). Clean .ssh/known_hosts from same ip record.
    ansible-playbook playbook-provision.yml -i production/inventory -u vagrant -l all --tags firewall --ask-pass

