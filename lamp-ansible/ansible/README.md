# ANSILBE USE
## Run playbook. Make sure you clean host's ~/.ssh/known_hosts from same guest ip.
    ansible-playbook <playbook path> -i <inventory path> -l all --tags <task name> --ask-pass