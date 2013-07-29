#!/bin/bash
set -e
source "${DPATH}"/config.ini
#======================================| Import Variables
# Make sure you have edited this file

cd ~



#======================================| Drush
if [[ ${INSTALL_DRUSH} == true ]]; then
  echo "**************************************************" | tee -a ${DLOGFILE}
  echo "**  Install drush                               **" | tee -a ${DLOGFILE}
  echo "**************************************************" | tee -a ${DLOGFILE}
  
  # Install using apt-get
  sudo apt-get ${APTGET_VERBOSE} install drush
  sudo drush dl drush -y --destination='/usr/share'
  
  # Install drush
 # sudo pear upgrade --force Console_Getopt
  #sudo pear upgrade --force pear
  #sudo pear upgrade-all
  #sudo pear channel-discover pear.drush.org
  #sudo pear install drush/drush

  mkdir ${HOME}/.drush

fi

#======================================| Email catcher
if [[ "${INSTALL_EMAIL_CATCHER}" == true ]]; then
  echo "**************************************************" | tee -a ${DLOGFILE}
  echo "**  Email catcher                               **" | tee -a ${DLOGFILE}
  echo "**************************************************" | tee -a ${DLOGFILE}
  # Configure email collector
  mkdir -p "${LOGS}/mail"
  # change group to apache (www-data)
  sudo chown :www-data "${LOGS}"
  sudo chown -R :www-data "${LOGS}/mail"
  # setup permissions
  sudo chmod -R ug=rwX,o= "${LOGS}/mail"
  # uncomment sendmail_path in php.ini
  sudo sed -i 's|'";.*sendmail_path.*="'|'"sendmail_path ="'|g' /etc/php5/apache2/php.ini /etc/php5/cli/php.ini
  # replace any existing sendmail_path with path to email catcher
  sudo sed -i 's|'"sendmail_path =.*"'|'"sendmail_path = ${HOME}/${DSCRIPTS}/resources/sendmail.php"'|g' /etc/php5/apache2/php.ini /etc/php5/cli/php.ini
  # ensure its in apache group
  sudo chown -R :www-data "${HOME}/${DSCRIPTS}/resources/sendmail.php"
  # ensure its readable by apache
  sudo chmod o=,ug+x ${HOME}/${DSCRIPTS}/resources/sendmail.php
fi

#======================================| XDebug Debugger/Profiler
# Configure xdebug - installed 2.1 from apt
if [[ "${INSTALL_XDEBUG}" == true ]]; then
  echo "**************************************************" | tee -a ${DLOGFILE}
  echo "**  XDebug Debugger/Profiler                    **" | tee -a ${DLOGFILE}
  echo "**************************************************" | tee -a ${DLOGFILE}
  echo "
  xdebug.remote_enable=on
  xdebug.remote_handler=dbgp
  xdebug.remote_host=localhost
  xdebug.remote_port=9000
  xdebug.profiler_enable=0
  xdebug.profiler_enable_trigger=1
  xdebug.profiler_output_dir=${LOGS}/profiler
  " | sudo tee -a /etc/php5/conf.d/xdebug.ini > /dev/null

fi    # XDEBUG

#======================================| XHProf profiler (Devel Module)
# Adapted from: http://techportal.ibuildings.com/2009/12/01/profiling-with-xhprof/
if [[ "${INSTALL_XHPROF}" == true ]]; then
  echo "**************************************************" | tee -a ${DLOGFILE}
  echo "**  XHProf Profiler                             **" | tee -a ${DLOGFILE}
  echo "**************************************************" | tee -a ${DLOGFILE}
  # supporting packages
  sudo apt-get ${APTGET_VERBOSE} install graphviz

  # get it
  cd ~
  wget ${WGET_VERBOSE} --referer="${REFERER}" --user-agent="${USERAGENT}" --header="${HEAD1}" --header="${HEAD2}" --header="${HEAD3}" --header="${HEAD4}" --header="${HEAD5}" "${XHPROF_URL}"
  tar xvf xhprof-0.9.2.tgz
  mv xhprof-0.9.2 "${LOGS}/xhprof"
  rm xhprof-0.9.2.tgz
  rm package.xml

  # build and install it
  cd ${LOGS}/xhprof/extension/
  phpize
  ./configure
  make
  sudo make install

  # configure php
  echo "
[xhprof]
extension=xhprof.so
xhprof.output_dir=\"${LOGS}/xhprof\"" | sudo tee /etc/php5/conf.d/xhprof.ini > /dev/null

  # configure apache
  echo "Alias /xhprof ${LOGS}/xhprof/xhprof_html

  <Directory ${LOGS}/profiler/xhprof/xhprof_html>
    Allow from All
  </Directory>
  " | sudo tee /etc/apache2/conf.d/xhprof > /dev/null

  chmod -R ug=rwX,o= "${LOGS}/xhprof"
fi

echo "**************************************************" | tee -a ${DLOGFILE}
echo "**  Restart apache                             **" | tee -a ${DLOGFILE}
echo "**************************************************" | tee -a ${DLOGFILE}
#======================================| Restart apache
sudo /etc/init.d/apache2 restart #use sysvinit scripts instead of upstart for more compatibility (debian, older ubuntu, etc)
