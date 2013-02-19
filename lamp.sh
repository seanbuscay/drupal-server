#!/bin/bash
set -e
source "${DPATH}"/config.ini

#======================================| Drupal sites
# Create folder for websites to live in
mkdir -p "${WWW_ROOT}"
sudo chown :www-data "${WWW_ROOT}"
sudo chmod -R u=rwX,g=rX,o= "${WWW_ROOT}"

#======================================| Install LAMP packages
# Define package names, and debconf config values.  Keep package names in sync.
LAMP_APACHE="libapache2-mod-php5 php-pear"

#======================================| Prepare PHP
LAMP_PHP="php5 php-apc php5-cli php5-curl php5-gd php5-imap php5-mcrypt php5-xsl php5-sqlite"

#======================================| Prepare MYSQL
LAMP_MYSQL="mysql-server libmysqlclient18 mysql-common"
echo mysql-server-5.5 mysql-server/root_password        password ${MYSQL_PASS} | sudo debconf-set-selections
echo mysql-server-5.5 mysql-server/root_password_again  password ${MYSQL_PASS} | sudo debconf-set-selections
LAMP_PHP="$LAMP_PHP php5-mysql"

if [[ "${INSTALL_XDEBUG}" == true ]]; then
  LAMP_PHP="$LAMP_PHP php5-xdebug"
fi

# Now install the packages.  debconf shouldn't need to ask so many questions.
sudo apt-get ${APTGET_VERBOSE} install $LAMP_MYSQL $LAMP_APACHE $LAMP_PHP
sudo apt-get ${APTGET_VERBOSE} install $LAMP_TOOLS

echo "**************************************************" | tee -a ${DLOGFILE}
echo "**  LAMP INSTALL COMPLETE                       **" | tee -a ${DLOGFILE}
echo "**************************************************" | tee -a ${DLOGFILE}

echo "**************************************************" | tee -a ${DLOGFILE}
echo "**  Configure APACHE                            **" | tee -a ${DLOGFILE}
echo "**************************************************" | tee -a ${DLOGFILE}

# ###### Configure APACHE
echo "ServerName ${WWW_FQDN}" | sudo tee /etc/apache2/conf.d/fqdn
sudo a2enmod ssl
sudo a2enmod rewrite
sudo a2dismod cgi
sudo a2dismod autoindex
# configure default site
echo "<VirtualHost *:80>
  DocumentRoot /var/www
  <Directory /var/www/>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride All
    Order allow,deny
    allow from all
  </Directory>
</VirtualHost>" | sudo tee /etc/apache2/sites-available/000-default  > /dev/null
sudo a2ensite 000-default

# Fix ssl for easier virtual hosting
echo "NameVirtualHost *:80
Listen 80
<IfModule mod_ssl.c>
    NameVirtualHost *:443
    Listen 443
</IfModule>" | sudo tee /etc/apache2/ports.conf > /dev/null

echo "<IfModule mod_ssl.c>
<VirtualHost *:443>
  ServerAdmin webmaster@localhost
  DocumentRoot /var/www
  <Directory />
    Options FollowSymLinks
    AllowOverride None
  </Directory>
  <Directory /var/www/>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride None
    Order allow,deny
    allow from all
  </Directory>
  SSLEngine on
  SSLCertificateFile    /etc/ssl/certs/ssl-cert-snakeoil.pem
  SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
</VirtualHost>
</IfModule>" | sudo tee /etc/apache2/sites-available/default-ssl > /dev/null
sudo a2ensite default-ssl

echo "**************************************************" | tee -a ${DLOGFILE}
echo "**  Configure MYSQL                             **" | tee -a ${DLOGFILE}
echo "**************************************************" | tee -a ${DLOGFILE}
#======================================| Configure MYSQL

sudo sed -i 's/#log_slow_queries/log_slow_queries/g'          /etc/mysql/my.cnf
sudo sed -i 's/#long_query_time/long_query_time/g'            /etc/mysql/my.cnf

echo "**************************************************" | tee -a ${DLOGFILE}
echo "**  Configure PHP                               **" | tee -a ${DLOGFILE}
echo "**************************************************" | tee -a ${DLOGFILE}
#======================================| Configure PHP
# sudo sed -i 's/find_this/replace_with_this/g' infile1 infile2 etc
sudo sed -i 's/magic_quotes_gpc = On/magic_quotes_gpc = Off/g'                       /etc/php5/apache2/php.ini /etc/php5/cli/php.ini
sudo sed -i 's/short_open_tag = On/short_open_tag = Off/g'                           /etc/php5/apache2/php.ini /etc/php5/cli/php.ini
sudo sed -i 's/max_execution_time = 30/max_execution_time = 300/g'                   /etc/php5/apache2/php.ini /etc/php5/cli/php.ini
sudo sed -i 's/memory_limit = 128M/memory_limit = 256M/g'                            /etc/php5/apache2/php.ini
sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 50M/g'                 /etc/php5/apache2/php.ini /etc/php5/cli/php.ini
sudo sed -i 's/post_max_size = 8M/post_max_size = 50M/g'                             /etc/php5/apache2/php.ini /etc/php5/cli/php.ini
sudo sed -i 's/;error_log = filename/error_log = \/var\/log\/php-error.log/g'        /etc/php5/apache2/php.ini /etc/php5/cli/php.ini # php 5.2
sudo sed -i 's/;error_log = php_errors.log/error_log = \/var\/log\/php-error.log/g'  /etc/php5/apache2/php.ini /etc/php5/cli/php.ini # php 5.3
sudo sed -i 's/display_errors = Off/display_errors = On/g'                           /etc/php5/apache2/php.ini /etc/php5/cli/php.ini
sudo sed -i 's/display_startup_errors = Off/display_startup_errors = On/g'           /etc/php5/apache2/php.ini /etc/php5/cli/php.ini

# Fix comment bug that will show warning on command line
sudo sed -i 's/# /\/\/ /g'            /etc/php5/cli/conf.d/mcrypt.ini
sudo sed -i 's/# /\/\/ /g'            /etc/php5/cli/conf.d/imap.ini

echo "**************************************************" | tee -a ${DLOGFILE}
echo "**  Install upload progress                     **" | tee -a ${DLOGFILE}
echo "**************************************************" | tee -a ${DLOGFILE}
# Install upload progress (warning in D7)

sudo pecl -q install uploadprogress
echo "extension=uploadprogress.so" | sudo tee /etc/php5/apache2/conf.d/uploadprogress.ini > /dev/null


echo "**************************************************" | tee -a ${DLOGFILE}
echo "**  Log Files                                   **" | tee -a ${DLOGFILE}
echo "**************************************************" | tee -a ${DLOGFILE}
#======================================| Log Files
mkdir -p "${LOGS}"


# Apache error logs are configured in the VirtualHosts section of each website (default from apache2.conf)
sudo touch     /var/log/apache2/error.log
sudo chmod g+w /var/log/apache2/error.log
ln -s          /var/log/apache2/error.log                "${LOGS}/apache-error.log"
# This file catches any unconfigured log info for virtualhosts (default from apache2.conf)
sudo touch     /var/log/apache2/other_vhosts_access.log
sudo chmod g+w /var/log/apache2/other_vhosts_access.log
ln -s          /var/log/apache2/other_vhosts_access.log  "${LOGS}/apache-access.log"
# php error logs are configured in php.ini  (changed in install-3-lamp.sh)
sudo touch     /var/log/php-error.log
sudo chmod g+w /var/log/php-error.log
ln -s          /var/log/php-error.log                    "${LOGS}/php-error.log"
# MySQL error and slow query logs (changed in install-2-lamp.sh)
sudo touch     /var/log/mysql/error.log
sudo chmod g+w /var/log/mysql/error.log
ln -s          /var/log/mysql/error.log                  "${LOGS}/mysql-error.log"
sudo touch     /var/log/mysql/mysql-slow.log
sudo chmod g+w /var/log/mysql/mysql-slow.log
ln -s          /var/log/mysql/mysql-slow.log             "${LOGS}/mysql-slow.log"


echo "**************************************************" | tee -a ${DLOGFILE}
echo "**  Config Files                                **" | tee -a ${DLOGFILE}
echo "**************************************************" | tee -a ${DLOGFILE}
#======================================| Config Files
mkdir -p "${CONFIGS}"
sudo chmod -R g+w /etc/apache2
ln -s /etc/apache2/apache2.conf      "${CONFIGS}/apache2.conf"
ln -s /etc/apache2/httpd.conf        "${CONFIGS}/httpd.conf"
ln -s /etc/apache2/ports.conf        "${CONFIGS}/ports.conf"
ln -s /etc/apache2/sites-enabled/    "${CONFIGS}/apache-sites-enabled"
sudo chmod -R g+w /etc/php5
ln -s /etc/php5/apache2/php.ini      "${CONFIGS}/php-apache.ini"
ln -s /etc/php5/cli/php.ini          "${CONFIGS}/php-cli.ini"
sudo chmod -R g+w /etc/mysql
ln -s /etc/mysql/my.cnf              "${CONFIGS}/mysql.cnf"
sudo chmod g+w /etc/hosts
ln -s /etc/hosts                     "${CONFIGS}/hosts"

#======================================| user management
# Make user of group www-data
sudo adduser $USER www-data

echo "**************************************************" | tee -a ${DLOGFILE}
echo "**  Restart web server                          **" | tee -a ${DLOGFILE}
echo "**************************************************" | tee -a ${DLOGFILE}
# ###### Restart web server

sudo /etc/init.d/mysql restart      #use sysvinit scripts instead of upstart for more compatibility (debian, older ubuntu, etc)
sudo /etc/init.d/apache2 restart    #use sysvinit scripts instead of upstart for more compatibility (debian, older ubuntu, etc)
