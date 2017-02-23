# Composer install - PHP package manager
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
  ln -s /usr/local/bin/composer /usr/bin/composer

# Drush install - Drupal admin utility
  composer global require drush/drush:dev-master
  cat export PATH="$HOME/.composer/vendor/bin:$PATH" >> ~/.bash_profile
  composer global update