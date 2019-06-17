
# Ansible Playbooks for RHTE

Ansible playbooks for installing Red Hat Tech Exchange 2019 Business Automation Labs

Prerequisites:

* Log in into Openshift as admin user.

Provision:

```console
ansible-playbook playbooks/hr_hiring.yml -e ocp_user=user1
```

Provision for a range of users:

```console
ansible-playbook playbooks/install.yml -e seq_start=1 -e seq_end=10
```

== OCP

oc login https://master00-71b4.generic.opentlc.com:443 -u admin -p r3dh4t1!

== rh-sso-multi-realm

=== URLs

. master realm
.. https://sso-rhsso-sso0.apps-71b4.generic.opentlc.com/auth/admin/master/console/   :  master /master

== rhpam-dev-ansible

=== provision
-----


use_custom_pam=true
ocp_user=user1
use_cluster_quota=true
kieserver_image_namespace=rhpam-dev-$guid
businesscentral_image_namespace=rhpam-dev-$guid
ansible-playbook playbooks/rhpam_dev.yml     -e ocp_user=$ocp_user     -e guid=$guid     -e use_cluster_quota=$use_cluster_quota     -e kieserver_image_namespace=$kieserver_image_namespace     -e businesscentral_image_namespace=$businesscentral_image_namespace     -e use_custom_pam=$use_custom_pam

-----

=== URLs

. BC
.. rhpam-bc-rhpam-dev-user1.apps-71b4.generic.opentlc.com   :   adminUser / admin1!
