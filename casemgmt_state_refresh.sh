new_guid=`echo $HOSTNAME | cut -d'.' -f 1 | cut -d'-' -f 2`
stale_guid=`cat $HOME/guid`
pam_project=rhpam-dev-user1
sso_project=rhsso-sso0

enableLetsEncryptCertsOnRoutes() {
    oc delete project prod-letsencrypt
    oc new-project prod-letsencrypt
    oc create -fhttps://raw.githubusercontent.com/gpe-mw-training/openshift-acme/master/deploy/letsencrypt-live/cluster-wide/{clusterrole,serviceaccount,imagestream,deployment}.yaml -n prod-letsencrypt
    oc adm policy add-cluster-role-to-user openshift-acme -z openshift-acme -n prod-letsencrypt

    echo -en "metadata:\n  annotations:\n    kubernetes.io/tls-acme: \"true\"" > /tmp/route-tls-patch.yml
    oc patch route rhpam-bc --type merge --patch "$(cat /tmp/route-tls-patch.yml)" -n $pam_project
    oc patch route rhpam-kieserver --type merge --patch "$(cat /tmp/route-tls-patch.yml)" -n $pam_project
    oc patch route sso --type merge --patch "$(cat /tmp/route-tls-patch.yml)" -n $sso_project
}

restartRHSSO() {
    oc scale dc/sso-mysql --replicas=1 -n $sso_project
    sleep 10
    oc scale dc/sso-mysql --replicas=1 -n $sso_project
    sleep 10
}

refreshPAM() {
    echo -en "\nwill update the following stale guid in the Process Automation Manager: $stale_guid\n\n"
    wait_for_bc=15

    # Switch to namespace of API Manager Control Plane
    oc project $pam_project

    # Restart KIE Server Postgresql
    oc scale dc/rhpam-postgresql --replicas=1 -n $pam_project

    # Will need to delete and re-create BC's PVC
    #   When modifying dc/rhpam-bc, the owning user of the files on the PVC switches from "jboss" to a random UID
    #   The subsequent rhpam-bc container is unable to then write to this PVC
    oc delete pvc rhpam-bc-claim -n $pam_project

    cat >/tmp/pvc.yml <<EOL
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  annotations:
  labels:
    application: rhpam
    service: rhpam-bc
  name: rhpam-bc-claim
  namespace: rhpam-dev-user1
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOL
    oc create -n $pam_project -f /tmp/pvc.yml



    #### Update BC with correct SSO_URL
    oc patch dc/rhpam-bc -p '{"spec":{"template":{"spec":{"containers":[{"name":"rhpam-bc","env":[{"name":"SSO_URL","value":"https://sso-rhsso-sso0.apps-'$new_guid'.generic.opentlc.com/auth"}]}]}}}}'
    oc rollout resume dc/rhpam-bc -n $pam_project

    echo -en "\nPause for the following number of seconds: $wait_for_bc \n"
    sleep $wait_for_bc



    #### Update Kie-server with correct SSO_URL
    oc patch dc/rhpam-kieserver -p '{"spec":{"template":{"spec":{"containers":[{"name":"rhpam-kieserver","env":[{"name":"SSO_URL","value":"https://sso-rhsso-sso0.apps-'$new_guid'.generic.opentlc.com/auth"},{"name":"SSO_PRINCIPAL_ATTRIBUTE","value":"preferred_username"}]}]}}}}'
    oc rollout resume dc/rhpam-kieserver -n $pam_project
}

#enableLetsEncryptCertsOnRoutes
restartRHSSO
refreshPAM

echo $new_guid > $HOME/guid
