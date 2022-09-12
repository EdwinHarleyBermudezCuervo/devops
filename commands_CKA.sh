kubectl get namespaces
kubectl create namespace apps
kubectl get svc

kubectl create namespace apps

## apps-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: apps

kubectl apply -f apps-namespace.yaml

############################################
Creating the ServiceAccount
############################################

kubectl create serviceaccount api-access -n apps

## api-serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: api-access
  namespace: apps

kubectl apply -f api-serviceaccount.yaml
kubectl get serviceaccount -n apps

#############################################
Creating a ClusterRole and ClusterRoleBinding
#############################################
kubectl create clusterrole api-clusterrole --verb=watch,list,get --resource=pods

#api-clusterrole.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: api-clusterrole
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["watch","list","get"]

kubectl apply -f api-clusterrole.yaml
kubectl get clusterrole api-clusterrole

#############################################
Creating the ClusterRoleBinding
#############################################

kubectl create clusterrolebinding api-clusterrolebinding --serviceaccount=apps:api-access --clusterrole=api-clusterrole

#api-clusterrolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: api-clusterrolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: api-clusterrole
subjects:
- apiGroup: ""
  kind: ServiceAccount
  name: api-access
  namespace: apps

kubectl apply -f api-clusterrolebinding.yaml
kubectl get clusterrolebinding api-clusterrolebinding


#############################################
Using the ServiceAccount in a Pod
#############################################

kubectl run operator --image=nginx:1.21.1 --restart=Never --port=80 --serviceaccount=api-access -n apps
kubectl create namespace rm
kubectl run disposable --image=nginx:1.21.1 --restart=Never -n rm

#rm-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: rm

# api-pods.yaml
apiVersion: v1
kind: Pod
metadata:
  name: operator
  namespace: apps
spec:
  serviceAccountName: api-access
  containers:
  - name: operator
    image: nginx:1.21.1
    ports:
    - containerPort: 80
---
apiVersion: v1
kind: Pod
metadata:
  name: disposable
  namespace: rm
spec:
  containers:
  - name: disposable
    image: nginx:1.21.1

kubectl apply -f rm-namespace.yaml
kubectl apply -f api-pods.yaml


kubectl get pod operator -n apps
kubectl get pod disposable -n rm

#############################################
Verifying the Permissions
#############################################

kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}'
# https://172.25.32.5:6443

kubectl get secret $(kubectl get serviceaccount api-access -n apps -o jsonpath='{.secrets[0].name}') -o jsonpath='{.data.token}' -n apps | base64 --decode

kubectl exec operator -n apps -- curl https://172.25.32.5:6443/api/v1/namespaces/rm/pods --header "Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6ImZzcFVDbWJfWkE1QU9vQXpqNUV1RVdDSjF6WHhvV0FMdmtuS185VEY5em8ifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJhcHBzIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImFwaS1hY2Nlc3MtdG9rZW4taG05OGIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiYXBpLWFjY2VzcyIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjlmM2ZhZGVjLTMwNGMtNDcxOS05N2ExLWNjMGYxNjcwZGY0MyIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDphcHBzOmFwaS1hY2Nlc3MifQ.sHbLnsWlSTod2RlX5lB-VXfw1eO86gkaSci4HW6GND2mrE1b--YPeOziQ9z0zBWUYUt26EMKMkYCZFMUYp21sDSWRWWrlF8hbyGAy2mA2uGZQmGLntUuTRu4kZILWPCmzpIqD_SfD7fmvoFDoAxyXkfP0W6qQOb8PH9ItomTJDEtYo-YGePALfK6qZBW-zuPf6GnIeOzvn6g1HOXXBTT6R0CN5b_0TdH0iH3YS1xsKp_RZ-RYdoLrDk2vYuU-zZuEbovnc_OpK70ZSDO7tPrsFX-0AMJRU_s2gqhWlx38gqJQ8Ke7c4y1KIXjOX-EC2gTU7nbojTpDNyT0j-4gvWCQ" --insecure


kubectl exec operator -n apps -- curl -X DELETE https://172.25.32.5:6443/api/v1/namespaces/rm/pods/disposable --header "Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6ImZzcFVDbWJfWkE1QU9vQXpqNUV1RVdDSjF6WHhvV0FMdmtuS185VEY5em8ifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJhcHBzIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImFwaS1hY2Nlc3MtdG9rZW4taG05OGIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC5uYW1lIjoiYXBpLWFjY2VzcyIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjlmM2ZhZGVjLTMwNGMtNDcxOS05N2ExLWNjMGYxNjcwZGY0MyIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDphcHBzOmFwaS1hY2Nlc3MifQ.sHbLnsWlSTod2RlX5lB-VXfw1eO86gkaSci4HW6GND2mrE1b--YPeOziQ9z0zBWUYUt26EMKMkYCZFMUYp21sDSWRWWrlF8hbyGAy2mA2uGZQmGLntUuTRu4kZILWPCmzpIqD_SfD7fmvoFDoAxyXkfP0W6qQOb8PH9ItomTJDEtYo-YGePALfK6qZBW-zuPf6GnIeOzvn6g1HOXXBTT6R0CN5b_0TdH0iH3YS1xsKp_RZ-RYdoLrDk2vYuU-zZuEbovnc_OpK70ZSDO7tPrsFX-0AMJRU_s2gqhWlx38gqJQ8Ke7c4y1KIXjOX-EC2gTU7nbojTpDNyT0j-4gvWCQ" --insecure




###################################################################
Creating a ConfigMap From Literal Values
###################################################################
kubectl create configmap env-configmap --from-literal=PROFILE=development --from-literal=DB_USERNAME=test -n data

apiVersion: v1
kind: ConfigMap
metadata:
  name: env-configmap
  namespace: data
data:
  PROFILE: development
  DB_USERNAME: test

kubectl apply -f configmap.yaml
kubectl get configmaps -A
kubectl get configmaps -n data
kubectl describe configmaps -n data env-configmap

kubectl run consumer --image=nginx --restart=Never -n data --dry-run=client -o yaml > pod.yaml

#pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: consumer
  namespace: data
spec:
  containers:
  - image: nginx
    name: nginx
    envFrom:
    - configMapRef:
        name: env-configmap
  restartPolicy: Never

kubectl apply -f pod.yaml
kubectl exec consumer -n data -- env