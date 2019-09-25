namespace=rhpam-dev-user1

oc scale dc/rhpam-postgresql --replicas=0 -n $namespace
oc delete pvc rhpam-postgresql -n $namespace

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

oc scale dc/rhpam-postgresql --replicas=1 -n $namespace
