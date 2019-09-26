failed_status=MatchNodeSelector
sso_namespace=rhsso-sso0
pam_namespace=rhpam-dev-user1


function deleteMatchNodeSelectorPods() {
  for pod in `oc get pods -n $namespace -o template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'`; do \
    reason=`oc get pod $pod -o template --template {{.status.reason}} -n $namespace`;

    echo -en "$pod $reason\n" ;

    if [[ "$failed_status" == "$reason" ]]; then
      echo -n "will delete:  $pod $reason" ;
      echo -en '\n\n';
      oc delete pod $pod -n $namespace
    fi
  done
}

function fix_pam() {
  oc get pods -n $pam_namespace
  sleep 3  
  echo -en "\n"
  oc scale dc/rhpam-postgresql --replicas=0 -n $pam_namespace
  oc delete pvc rhpam-postgresql -n $pam_namespace

echo "apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  annotations:
  labels:
    app: rhpam
  name: rhpam-postgresql
  namespace: rhpam-dev-user1
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi" | oc create -f -

  oc scale dc/rhpam-postgresql --replicas=1 -n $pam_namespace
}

function fix_all() {
    namespace=$sso_namespace
    deleteMatchNodeSelectorPods 
  
    namespace=$pam_namespace
    deleteMatchNodeSelectorPods 
  
    fix_pam
}

function iterate_through_guids() {
  while read p; do
  
    echo -en "\n\n\n$p\n"
    host master00-$p.generic.opentlc.com
    oc login -u admin -p r3dh4t1! https://master00-$p.generic.opentlc.com --insecure-skip-tls-verify=true
    responseCode=$?
    if [ $responseCode -ne 0 ];then
      echo -en "\nError with the following guid :  $p    $responseCode\n"
      echo -en "$p" >> $error_file
    fi
  
    fix_all
  
  done </tmp/availableguids-R2015.csv
}

#iterate_through_guids
fix_all
