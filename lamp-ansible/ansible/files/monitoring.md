## Monit + alert
================
# Install monit
  sudo apt-get install monit
  sudo vi /etc/monit/monitrc
  monit status
# Install ssmtp
  sudo apt-get install ssmtp
  sudo vi /etc/ssmtp/ssmtp.conf
  ssmtp recipient_name@gmail.com < filename.txt


### Handle Files

# Copy files between servers
  scp /path/to/file username@a:/path/to/destination
  

### System
==========
## Autostart
# To start a daemon at startup:
  update-rc.d service_name defaults
# To remove:
  update-rc.d -f service_name remove

## Reboot
# Shutdown
  sudo shutdown -h now
# Restart
  sudo shutdown -r now