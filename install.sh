#!/bin/bash
set -e

export DSCRIPTS="drupal-server"
export DPATH="${HOME}/${DSCRIPTS}"
export DLOGFILE="${HOME}/${DSCRIPTS}/install.log"

source "${DPATH}"/config.ini

## Upgrade
echo "**************************************************" | tee -a ${DLOGFILE}
echo "**  Start Apt-Get Update                        **" | tee -a ${DLOGFILE}
echo "**************************************************" | tee -a ${DLOGFILE}
sudo apt-get -yq update
echo "**************************************************" | tee -a ${DLOGFILE}
echo "**  Start Apt-Get Upgrade                        **" | tee -a ${DLOGFILE}
echo "**************************************************" | tee -a ${DLOGFILE}
## Don't upgrade
## sudo apt-get -yq upgrade

## Add Dependencies Early
echo "**************************************************" | tee -a ${DLOGFILE}
echo "**  Install PHP5-dev                            **" | tee -a ${DLOGFILE}
echo "**************************************************" | tee -a ${DLOGFILE}
## For Ubuntu 12.04 (LTS)
sudo apt-get ${APTGET_VERBOSE} install build-essential

# Install Vbox Specific Tweaks
if [[ "${INSTALLTYPE}" == "vbox" ]]; then
  echo "**************************************************" | tee -a ${DLOGFILE}
  echo "**  Install Vbox Items                          **" | tee -a ${DLOGFILE}
  echo "**************************************************" | tee -a ${DLOGFILE}
  bash "${DPATH}"/vbox.sh 2>&1 | tee -a ${DLOGFILE}
fi

sudo apt-get ${APTGET_VERBOSE} install php5-dev

# Install LAMP
echo "**************************************************" | tee -a ${DLOGFILE}
echo "**  Install LAMP                                **" | tee -a ${DLOGFILE}
echo "**************************************************" | tee -a ${DLOGFILE}
bash "${DPATH}"/lamp.sh 2>&1 | tee -a ${DLOGFILE}
sudo chmod -R u=rwX,g=rX,o= /var/www 2>&1 | tee -a ${DLOGFILE}
sudo chown -R $USER:www-data /var/www 2>&1 | tee -a ${DLOGFILE}

# Install Tools
echo "**************************************************" | tee -a ${DLOGFILE}
echo "**  Install Tools                               **" | tee -a ${DLOGFILE}
echo "**************************************************" | tee -a ${DLOGFILE}
bash "${DPATH}"/tools.sh 2>&1 | tee -a ${DLOGFILE}
# Install Jenkins
if [[ "${INSTALL_JENKINS}" == true ]]; then
  echo "**************************************************" | tee -a ${DLOGFILE}
  echo "**  Install Jenkins                             **" | tee -a ${DLOGFILE}
  echo "**************************************************" | tee -a ${DLOGFILE}
  bash "${DPATH}"/misc/install-jenkins.sh 2>&1 | tee -a ${DLOGFILE}
fi

if [[ "${INSTALL_MEMCACHED}" == true ]]; then
  echo "**************************************************" | tee -a ${DLOGFILE}
  echo "**  Install MEMCACHED                           **" | tee -a ${DLOGFILE}
  echo "**************************************************" | tee -a ${DLOGFILE}
  bash "${DPATH}"/misc/install-memcached.sh 2>&1 | tee -a ${DLOGFILE}
fi

if [[ "${INSTALL_SOLR}" == true ]]; then
  echo "**************************************************" | tee -a ${DLOGFILE}
  echo "**  Install SOLR                                **" | tee -a ${DLOGFILE}
  echo "**************************************************" | tee -a ${DLOGFILE}
  bash "${DPATH}"/misc/install-solr.sh 2>&1 | tee -a ${DLOGFILE}
fi
