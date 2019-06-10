
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