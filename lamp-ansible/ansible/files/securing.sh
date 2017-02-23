# Securing servers

# Secure Debian/Ubuntu by removing root login with password. Allow only private key auth.
# 1. Add text
echo PermitRootLogin without-password >> /etc/ssh/sshd_config
# 2. Kill/Restart SSH daemon so that the change takes place
# ps auxw | grep ssh
# kill -HUP {SOME_PS_NUM}
# OR
service ssh restart