#!/bin/bash

echo "export OCP_USERNAME=user1" >> ~/.bashrc
echo 'export OCP_PASSWD=r3dh4t1!' >> ~/.bashrc

echo "export OCP_REGION=`echo $HOSTNAME | cut -d'.' -f1 | cut -d'-' -f2`" >> ~/.bashrc
echo "export OCP_DOMAIN=\$OCP_REGION.generic.opentlc.com" >> ~/.bashrc
echo "export OCP_WILDCARD_DOMAIN=apps-\$OCP_DOMAIN" >> ~/.bashrc
echo "export rhsso_url=sso-rhsso-sso0.\$OCP_WILDCARD_DOMAIN" >> ~/.bashrc
echo "export bc_url=rhpam-bc-rhpam-dev-\$OCP_USERNAME.\$OCP_WILDCARD_DOMAIN" >> ~/.bashrc
echo "export ks_url=rhpam-kieserver-rhpam-dev-\$OCP_USERNAME.\$OCP_WILDCARD_DOMAIN" >> ~/.bashrc

echo "export RHPAM_PROJECT=rhpam-dev-\$OCP_USERNAME" >> ~/.bashrc
echo "export RHPAM_TOOLS_PROJECT=pam-7-tools-\$OCP_USERNAME" >> ~/.bashrc
echo "export RHSSO_PROJECT=rhsso_sso0" >> ~/.bashrc

source ~/.bashrc

