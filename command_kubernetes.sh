minikube start --no-vtx-check


#Install Kubernetes Servers
sudo apt update
sudo apt -y full-upgrade
[ -f /var/run/reboot-required ] && sudo reboot -f

# Install kubelet, kubeadm and kubectl
sudo apt -y install curl apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt -y install vim git curl wget kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

kubectl version --client && kubeadm version
kubectl version --short


# Disable Swap
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo swapoff -a


# Enable kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Add some settings to sysctl
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload sysctl
sudo sysctl --system

Step 4: Install Container runtime

# Add repo and Install packages
sudo apt update
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y containerd.io docker-ce docker-ce-cli

# Create required directories
sudo mkdir -p /etc/systemd/system/docker.service.d

# Create daemon json config file
sudo tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Start and enable Services
sudo systemctl daemon-reload 
sudo systemctl restart docker
sudo systemctl enable docker


********************************************************************************************
kubectl version --client
kubectl version --short --output=yaml

#Create Deployment
kubectl create deployment hello-world --image=k8s.gcr.io/echoserver:1.4
kubectl get deployments
kubectl get pods
kubectl get events

#Create Service
kubectl expose deployment hello-node --type=LoadBalancer --port=8080
kubectl get services
kubectl expose deployment hello-node --type=NodePort
kubectl get all

#Pods system
kubectl get pod,svc -n kube-system

kubectl create -f helloworld.yaml
kubectl expose deployment helloworld --type=NodePort
kubectl get all
kubectl get deployment/helloworld -o yaml
kubectl get service/helloworld -o yaml

kubectl get pods --show-labels
kubectl label  po/helloworld app=helloworldapp --overwrite
kubectl get pods --show-labels
kubectl label po/helloworld app-     #delete label

#search
kubectl get pods --selector env=production
kubectl get pods --selector env=production --show-labels
kubectl get pods --selector dev-lead=karthik,env=staging
kubectl get pods --selector dev-lead!=karthik,env=staging --show-labels
kubectl get pods --selector dev-lead=carisa

kubectl get pods -l 'release-version in (1.0,2.0)' --show-labels
kubectl get pods -l 'release-version notin (1.0,2.0)' --show-labels

kubectl delete pod --selector application_type=api

kubectl get pods --show-labels
kubectl delete pods -l dev-lead=karthik

kubectl get replicaset

kubectl set image deployment/navbar-deployment helloworld=karthequian/helloworld:blue
kubectl get rs
 
kubectl rollout history deployment/navbar-deployment
kubectl rollout undo deployment/navbar-deployment

#Access to pod
kubectl exec -it helloworld-deployment-with-bad-readiness-probe-d9dc4cb64-hcjkl /bin/bash

Kubectl run hello-world

Kubectl cluster-info
kubectl cluster-info dump

Kubectl get nodes
kubectl run nginx --image=nginx

kubectl get pods
kubectl describe pod nginx
kubectl describe pod newpods-bcvm4 |grep -i image

kubectl describe pods -n kube-system  fluentd-hrtqs

kubectl get pods -o wide
kubectl get pods webapp
kubectl describe pod webapp |grep -i image

kubectl delete pod webapp
kubectl delete daemonsets.apps -n kube-system fluentd

kubectl run redis --image=redis123 --dry-run=client -o yaml > pod.yaml
kubectl apply -f prod.yaml
kubectl edit pod redis

kubectl create -f pod-definition.yaml



vim pod.yaml
	apiversion: v1
	kind: Pod
	metadata:
		name: nginx
		labels:
			app: nginx
			tier:  frontend			
	Spec:
		containers:
		- name: nginx
		  image: nginx
		- name: busybox
		  image: busybox 	

-----Database Postgres --------
apiVersion: v1
kind: Pod
metadata:
  name: postgres
  labels:
    tier: db-tier
spec:
  containers:
    - name: postgres
      image: postgres
      env:
        - name: POSTGRES_PASSWORD
          value: mysecretpassword

#####################################		  
kubectl apply -f pod.yaml
kubectl describe nodes
kubectl

docker run python-app


----- REPLICATION CONTROLLER -----
kubectl create -f rc-definition.yml
kubectl get replicationcontroller


----- REPLICA SETS ----
Kubectl create -f replicaset-definition.yml
kubectl get replicaset
kubectl get pods

kubectl replace -f replicaset-definition.yml

kubectl scale --replicas=6 -f replicaset-definition.yml
kubectl scale --replicas=6  replicaset myapp-replicaset
kubectl scale --replicas=5 replicaset new-replica-set
kubectl edit replicasets.apps new-replica-set
Replicas=2


kubectl delete replicaset myapp-replicaset
kubectl delete replicasets.apps replicaset-1
kubectl delete replicasets.apps replicaset-2 

kubectl describe replicaset myapp-replicaset
kubectl apply -f replicaset-definition-yaml

kubectl edit replicasets.apps new-replica-set


---- DEPLOYMENTS ----
kubectl create -f deployment-definition.yml
kubectl get deployments
kubectl get replicaset
kubectl get pods

kubectl get all
kubectl get all -n kube-system
kubectl get all --all-namespaces
kubectl create deployment httpd-frontend --replicas=3 --image=httpd:2.4-alpine

---- ROLLOUT COMMAND ----
kubectl rollout status deployment/myapp-deployment
kubectl rollout history deployment/myapp-deployment

kubectl create -f deployment-definition.yml
kubectl create -f deployment-definition.yaml --record
kubectl get replicasets 
kubectl get deployments
kubectl apply -f deployment-definition.yml
kubectl set image deployment/myapp-deployment nginx=nginx:1.9.1
kubectl set image deployment/frontend kodekloud/webapp-color=kodekloud/webapp-color:v2
kubectl set image deployment/nginx-deployment  nginx=nginx:1.22.0 --record
1.22.0

kubectl describe deployments.apps frontend

kodekloud/webapp-color:v2

#rollback
kubectl rollout undo deployment/myapp-deployment
kubectl rollout undo deployment/nginx-deployment --to-revision=2


kubectl run frontend --image=kodekloud/webapp-color:v2 --dry-run=client -o yaml > frontend.yaml

#TROUBLESHOOTING
kubectl get po --namespace kube-system
kubectl get pods --namespace kube-system
kubectl get pods -n kube-system
kubectl get pod storage-provisioner --namespace kube-system
kubectl describe pod storage-provisioner --namespace kube-system
kubectl api-resources | less
kubectl api-versions

kubectl version --output=yaml
minikube start --vm-driver="hyperv" --hyperv-virtual-switch="Minikube"


---SERVICE -----
kubectl create -f service-definition.yaml
kubectl get services
curl http://192.1568.1.2:30008


minikube service myapp-service --url

kubectl get services
kubectl get svc
kubectl get services -o wide
kubectl describe service kubernetes
kubectl describe services

kubectl get deployment
kubectl describe deployment

kubectl expose deployment simple-webapp-deployment --name=webapp-service --target-port=8080 --type=NodePort --port=8080 --dry-run=client -o yaml > svc.yaml
kubectl expose deployment hello-minikube --type=NodePort --port=8080

docker run -d --name=redis redis
docker run -d --name=db postgres:9.4
docker run -d --name=vote -p 5000:80 --link redis:redis voting-app
docker run -d --name=result -p 5001:80 --link db:db result-vote
docker run -d --name=worker --link db:db --link redis:redis worker

kubectl create -f voting-app-pod.yaml 
kubectl create -f voting-app-service.yaml --validate=false

kubectl create -f redis-pod.yaml
kubectl create -f redis-service.yaml

kubectl get pods,svc

kubectl delete all -l app=explorecalifornia.com

kubectl port-forward svc/explorecalifornia-svc 8080:8080


## Helm 
-{{randAplhaNumber 5 | lower}}

helm show  all ./chart
mv {deployment,service,ingress}.yaml char/template

helm install explore-caliifornia-website ./char/template
helm unistall explore-caliifornia-website

helm upgrade --atomic -- install explore-caliifornia-website ./char
make install_app
	

##############################################################
DOCKER
##############################################################
cat /etc/*-release

docker --version
sudo yum install -y docker-ce
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum upgrade -y

docker image ls
which group docker 
whoami
sudo usermod -aG docker $USER

sudo systemctl start docker.service

docker login

*******************
dockerfile
*******************

FROM ubuntu:latest

RUN apt-get update -y &&install -y python python-pip

COPY ./requirerments.txt /python-app/requirerments.txt
COPY ./first-python-webpage.py /python-app/first-python-webpage.py

WORKDIR /python-app

RUN pip install -r requirerments.txt

EXPOSE 8080

ENTRYPOINT ["python2","first-python-webpage.py"]

********************

docker build -t aws-ecs -f /path/of/dockerfile
docker run --name aws-ecs -d -p 8080:8080 aws-ecs:latest
docker container ls
curl localhost/aws-ecs


docker image build -t fisrt-python:v1 ./
docker image ls
docker pull mongo

docker container ps
docker image inspect IMAGE_ID
docker image rm IMAGE_ID
docker image history IMAGE_ID

docker info

docker login
docker image push aws-ecs:latest
docker tag IMAGE_ID account_docker_hub/aws-ecs:latest
docker image tag IMAGE_ID myapp:latest
docker image tag e165ac941640 example:latest
docker image push account_docker_hub/aws-ecs:latest

docker container stop IMAGE_ID
docker run -d -e NAME="Cloud-DeepTech" --name aws-ecs-from-hub -p 8080:8080 account_docker_hub/aws-ecs:latest
curl localhost:8080

docker container ps -a
docker container logs IMAGE_ID

# access to container
docker exec -it  aws-ecs /bin/bash 
python --version
ps -ef


#Docker Network
docker network ls
docker network create --attachable -d bridge --subnet=10.20.0.0/16 aws-ecs
docker network inspect aws-ecs
docker container run -d -e NAME="Deep"  --name web --net aws-ecs -p 80:8080 first-python:v1

#Volumes & Bind Mounts


#Example Bill
docker pull sotobotero/udemy-devops:0.0.1
docker run -p 80:80 -p 8080:8080 --name billingapp sotobotero/udemy-devops:0.0.1

docker ps -a
docker image ls
docker volume ls
docker network ls

docker volume prune
docker system prune
docker network prune


docker container start docker
docker container stop docker
docker container stop 4884ea0aa16c

docker logs billingapp
docker container rm billingapp
docker image rm sotobotero/udemy-devops:0.0.1


#docker compose
docker pull postgres

docker compose -f stack-billing.yml build
docker compose -f stack-billing.yml up -d 
docker compose -f Stack-billing.yml stop

docker compose -f stack-billing.yml up -d --force-recreate
docker stop $(docker ps -a -q)

docker-compose -f stack-billing.yml build --no-cache
docker-compose -f stack-billing.yml up -d --force-recreate

----------------------------------------------------------------------------------
##################################################################################
## stack-billing.yml

version: '3.1'

services:
#database engine service
  postgres_db:
    container_name: postgres
    image: postgres:latest
    restart: always
    ports:
      - 5432:5432
    volumes:
        #allow *.sql, *.sql.gz, or *.sh and is execute only if data directory is empty
      - ./dbfiles:/docker-entrypoint-initdb.d
      - /var/lib/postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: qwerty
      POSTGRES_DB: postgres    
#database admin service
  adminer:
    container_name: adminer
    image: adminer
    restart: always
    depends_on: 
      - postgres_db
    ports:
       - 9090:8080
#Billin app backend service
  billingapp-back:
    build:
      context: ./java
      args:
        - JAR_FILE=*.jar
    container_name: billingApp-back      
    environment:
       - JAVA_OPTS=
         -Xms256M 
         -Xmx256M         
    depends_on:     
      - postgres_db
    ports:
      - 8080:8080 
#Billin app frontend service
  billingapp-front:
    build:
      context: ./angular 
    deploy:   
        resources:
           limits: 
              cpus: "0.15"
              memory: 250M
#recusos dedicados, mantiene los recursos disponibles del host para el contenedor
           reservations:
              cpus: "0.1"
              memory: 128M
    #container_name: billingApp-front
    depends_on:     
      - billingapp-back
#rango de puertos para escalar    
    ports:
      - 80:80 
----------------------------------------------------------------------------------
##################################################################################
#resources stadistics
docker stats 

# Use postgres/example user/password credentials
version: '3.1'

services:

  db:
    container_name: postgres
    image: postgres
    restart: always
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: admin123
      POSTGRES_DB: postgres
    ports:
      - 5432:5432
  
  adminer:
    container_name: adminer
    image: adminer
    restart: always
    depends_on:
      - db
    ports:
      - 9090:8080

docker-compose -f docker-compose.yml pull 
docker image ls
docker-compose -f docker-compose.yml up -d
docker stop e2d09d685f81
docker stop 7c3836421e62
docker container rm adminer postgres

## Dockerfile build image
docker build -t billingapp:prod --no-cache --build-arg JAR_FILE=target/*.jar .
docker build -t billingapp-back:0.0.4 --no-cache --build-arg JAR_FILE=./*.jar .
docker build -t billingapp-front:0.0.4 --no-cache .
docker run -p 80:80 -p 8080:8080 --name billingapp billingapp:prod

docker push ehbc/udemy-devops:tagname
docker tag billingapp:prod ehbc/udemy-devops:0.0.1
docker login
docker push ehbc/udemy-devops:0.0.1

FROM nginx:alpine


#install java 8
RUN apk -U add openjdk8 \
    && rm -rf /var/cache/apk/*;
RUN apk add ttf-dejavu

#install microservice
ENV JAVA_OPTS=""
ARG JAR_FILE
ADD ${JAR_FILE} app.jar
#install app on nginx server
#use a volume is more efficient speed that filesystem
VOLUME /tmp
RUN rm -rf /usr/share/nginx/html/*
COPY nginx.conf /etc/nginx/nginx.conf
COPY dist/billingApp /usr/share/nginx/html
COPY appshell.sh appshell.sh
#expose ports 8080 for java swagger app and 80 for nginx app
EEXPOSE 80 8080
ENTRYPOINT["sh", "/appshell.sh"]


*************************************************************************************************************************

sudo apt-get install openssh-server
ip addr
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update


## Install using the repository
https://docs.docker.com/engine/install/ubuntu/#set-up-the-repository


sudo apt-get update

sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo apt-get update

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

### Install Docker Engine

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
 #optional     apt-cache madison docker-ce
 #optional     sudo apt-get install docker-ce= 5:20.10.17~3-0~ubuntu-focal docker-ce-cli= 5:20.10.17~3-0~ubuntu-focal containerd.io docker-compose-plugin
sudo docker run hello-world

#Allow apt to use a Repository over HTTPS
sudo apt-get install apt-transport-https ca-certificates curl software-propierties-common

#Add the Docker official GPG key to Apt
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -


sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu/ $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce=17.12.0~ce-0~ubuntu
sudo apt-get install docker-ce=5:20.10.17~3-0~ubuntu-focal docker-ce-cli=5:20.10.17~3-0~ubuntu-focal containerd.io docker-compose-plugin


## Give permissions
sudo groupadd docker
sudo usermod -aG docker $USER

### Install docker compose
https://docs.docker.com/compose/install/
https://docs.docker.com/desktop/install/ubuntu/


sudo apt-get update
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose	
sudo curl -L "https://github.com/docker/compose/releases/download/v2.10.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose	
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose --version



#Universal Control Plane - UCP
docker run --rm -it --name ucp -v /var/run/docker.sock:/var/run/docker.sock docker/ucp:2.2.6 install --interactive

docker info | more
docker ps
docker ps -a
docker node space ls
docker info | grep 'Logging Driver'
docker run --log-driver=syslog --log-opt syslog-address=udp://1.1.1.1 alpine
 

docker login
docker pull alpine
docker images

docker tag d7d ehbc/Linkedin1

docker push ehbc/alpine:Linkedin1
docker pull ehbc/alpine:Linkedin1

#Delete images locally
docker image rm d7d
docker image rm d7d -f

systemctl status docker


#### DOCKER SWARM ####

#Active
docker swarm init
docker swarm init --advertise-addr 192.168.0.100 

docker swarm join --token SWMTKN-1-0ieu25jolav3jouh2u7v5gmd5j64wo5v6uo29i8mqou72xm5zt-bje5ykk5utfaosdyi4grq9hu3 192.168.0.100:2377


#Backing Up the Docker Swarm Cluster
systemctl stop docker
cd /var/lib/docker

copy and archive the swarm directory
cp -R swarm /tmp

systemctl start docker


#Docker Swarm 
docker swarm join --token SWMTKN-1-5j59zqyk68gesbh6ommbq3u8gkbvw5yricq3acsl9n0g1svyka-3d2wdzicdptpbhw3w9pfvs60a 172.31.149.76:2377

docker swarm join-token
docker swarm join-token worker
sdocker swarm join --token SWMTKN-1-5j59zqyk68gesbh6ommbq3u8gkbvw5yricq3acsl9n0g1svyka-3d2wdzicdptpbhw3w9pfvs60a 172.31.149.76:2377

docker service create --name webapp1 --replicas=6


### Unistall docker engine
sudo apt-get purge docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
docker image rmi node:12-alpine getting-started:latest -f



###  Install Docker

https://computingforgeeks.com/how-to-install-docker-swarm-on-ubuntu/

sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update

apt-cache policy docker-ce

sudo apt install docker-ce
systemctl status docker

sudo usermod -aG docker ${USER}
newgrp docker


INT_NAME="eth0" 
HOST_IP=$(ip addr show $INT_NAME | grep "inet\b" | awk '{print $2}' | cut -d/ -f1)
echo $HOST_IP


network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      addresses:
        - 10.10.10.2/24
      gateway4: 10.10.10.1
      nameservers:
          search: [mydomain, otherdomain]
          addresses: [10.10.10.1, 1.1.1.1]

network:
  version: 2
  renderer: networkd
  ethernets:
    enp3s0:
      dhcp4: true

sudo netplan apply

172.31.153.16 manager
172.31.155.172 worker01
172.31.153.33 worker02


ssh ehbc@172.31.153.16
ssh ehbc@172.31.153.33
ssh ehbc@172.31.155.172

sudo docker swarm init --advertise-addr $HOST_IP


# Deploy application

docker stack deploy -c stack-billing.yml billing
docker service ls
docker stack ps billing
docker stack ls

docker stactk rm billing



sudo docker service create --name web-server1 --publish 80:80 nginx:1.13-alpine
sudo docker service ls
sudo docker service scale web-server=3



Pull the latest version of UCP
docker image pull docker/ucp:2.2.6

# Install UCP
docker container run --rm -it --name ucp -v /var/run/docker.sock:/var/run/docker.sock docker/ucp:2.2.6 install  --host-address $HOST_IP --interactive

#Unistall UCP
docker container run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name ucp \
  docker/ucp:2.2.6 uninstall-ucp --interactive


docker run --rm -it --name ucp -v /var/run/docker.sock:/var/run/docker.sock docker/ucp install --host-address --interactive

docker ps -a
docker logs 17c142cb872c

docker swarm init --autolock
docker swarm update --autolock=true
	SWMKEY-1-T+l/QFb/2WdTV9pkFFHGhP0CVYd6dIxSUqQMpPpmkJg
sudo systemctl restart docker

docker swarm unlock-key	
docker swarm unlock-key --rotate
	SWMKEY-1-rV5aoJqbbJab0+pd7DYj3+yJ2vUmuZZNaLIqJFivz7Q

#Leave docker swarm
docker swarm leave --force
docker info

docker run -it -d -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock dockersamples/visualizer
docker service ls
docker ps |grep samples
ip a |grep eth0


#Inspect - details
man docker inspect
docker inspect web-server1 |more

docker ps
docker inspect CONTAINER_ID

docker service logs web-server1
docker node update --label-add prio1 DC1-N1
docker node inspect DC1-N1 | more

#Stack
docker stack deploy  --compose-file docker-stack.yaml my_stack
docker stack services  my_stack


#service
docker service update --publish-add published=8080, target=8080 mystack
docker service inspect my_stack |grep 8080
docker service create --mode global --name global-service nginx

#Volumes
docker service update --mount-add type=volume,source=web-vol,target=/web-vol-dir my_stack
docker volume ls


#Images
docker image prune -a

vi dockerfile
docker build .
docker images history ID_IMAGE


docker build -t getting-started .
docker run -dp 3000:3000 getting-started
docker run -it -dp 3080:3080 alpine:3.4
docker run --rm -it ubuntu:latest
	
	FROM ubuntu:latest
	RUN apt-get update
	RUN apt-get install nginx -Y
	RUN apt-get install python2 -y
	

Dockerfile
	FROM ubuntu
	
	LABEL Description "This image is used to start the foobar executable" Vendor "Products EHBC" Version "1.0"
	RUN apt-get update && apt-get install -y inotify-tools \
	nginx \ 
	apache2 \
	openssh-server
	

docker build -f ./dd-docker -t ubuntu:v2 .
docker build --squash -f ./dd-docker -t ubuntu:v3 .

docker container run -d ngnix
docker container export jovial_jackson > nginx.tar
docker image import nginx.tar
docker image history newnginx


docker image ls  === docker images 
docker image rm IMAGE_ID
docker image rmi IMAGE_ID IMAGE_ID
docker image prune
docker image prune -a 


docker container ls
docker image inspect ubuntu:latest > ubuntu-inspect.txt
docker image inspect getting-started:latest --format='{{.Id}}'
docker image inspect getting-started:latest --format='{{.ContainerConfig}}'
docker image inspect getting-started:latest --format='{{json .ContainerConfig}}'
docker image inspect getting-started:latest --format='{{json .ContainerConfig.Hostname}}'





docker ps -s  					##Show disk usage by container##
docker ps						##List containers UP##
docker ps -a					##Show both running and stopped containers##
docker ps -all
docker ps --no-trunc			##Prevent truncating output##
docker ps -a --filter 'exited=0'	##exited successfully##
docker ps --filter status=running   ##status##


#Docker Registry
docker run -d -p 5000:5000 --name registry registry:2
docker pull ubuntu
docker image tag ubuntu localhost:5000/myfirstimage
docker push localhost:5000/myfirstimage
docker pull localhost:5000/myfirstimage
docker container stop registry && docker container rm -v registry


#Docker DTR(Docker Trusted Registry)
docker pull docker/dtr:2.2.10
docker search nginx
docker search --limit=1 ubuntu 
docker search --filter "is-official=true" ubuntu 



docker image rm -force 3f8


#Install DTR
docker run -it --rm \
  docker/dtr:2.2.10 install \
  --ucp-node manager \
  --ucp-insecure-tls
  
docker run -it --rm docker/dtr install `  --ucp-node manager ` --ucp-username admin ` --ucp-url https://172.31.153.16 `  --ucp-insecure-tls


#Docker Storage
docker info |more
sudo systemctl stop docker
sudo cp -au /var/lib/docker/ $HOME
vi /etc/docker/daemon.json
	{
	"insecure-registries" : ["192.168.1.129"]
	"storage-driver": "overlay"
	}


docker volume inspect web-vol |more
cd /var/lib/docker/volumes
docker container run -d --mount source=ehbc-vol,target=/app nginx
docker volume inspect ehbc-vol


docker container run -d --mount type=bind,source=/tmp,target=/app nginx

docker volume create

#Network
docker network ls
docker network create
docker network inspect bridge
docker network create --driver bridge app-net
docker run -dit --name app1 --network app-net alpine ash
docker run -dit --name app2 --network app-net alpine ash
docker container attach app1
	ping app2
	
docker container stop app1 app2
docker container rm app1 app2
docker network rm app-net


docker network ls
docker network create --driver overlay app-overlay
docker network inspect app-overlay
docker service create --network app-overlay --name=app1 --replicas=6 nginx
docker service ls
docker ps |grep nginx

docker service update --replicas=0 app1
docker service rm app1

#Publish Ports
docker container run -dit -p 8080:80 nginx
docker container run -dit -P nginx
docker container stop 10f1678b089b


#DNS
docker container run -it --dns 172.31.153.16 centos /bin/bash
cat /etc/resolv.conf

sudo vi/etc/docker/daemon.json
	{
	"dns": [" 172.31.153.16"]
	}

sudo systemctl restart docker
docker container run -it centos /bin/bash
cat /etc/resolv.conf


#Host Network
docker container run -d --network host nginx
docker container port relax_lumiere
docker container port ucp-proxy


docker tag nginx:latest 172.31.155.172/admin/others/test:signed
export DOCKER_CONTENT_TRUST=1
docker login 172.31.155.172
docker push 172.31.155.172/admin/others/test:signed

***************************************************************************
#### Install kubeadm ###
***************************************************************************
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
https://www.containiq.com/post/kubeadm


https://github.com/sandervanvugt/cka

### prerequisites ###
#Validation MAC
ifconfig -a // ip link
sudo cat /sys/class/dmi/id/product_uuid
nc 127.0.0.1 6443
nc 127.0.0.1 10250

#Control plane
TCP	Inbound	6443	Kubernetes API server	All
TCP	Inbound	2379-2380	etcd server client API	kube-apiserver, etcd
TCP	Inbound	10250	Kubelet API	Self, Control plane
TCP	Inbound	10259	kube-scheduler	Self
TCP	Inbound	10257	kube-controller-manager	Self

#Worker node(s)
TCP	Inbound	10250	Kubelet API	Self, Control plane
TCP	Inbound	30000-32767	NodePort Services†	All


### Script validation Ports ####
cat > validationPort.sh << EOF
#!/bin/bash
validationport(){
    echo "$1"
    nc 127.0.0.1 $1
}

validationport  "6443"
validationport  "2379"
validationport  "2380"
validationport  "10250"
validationport  "10257"
validationport  "10259"
EOF


cat > validationPortWorkerNode.sh << EOF
#!/bin/bash
validationport(){
    echo "$1"
    nc 127.0.0.1 $1
}

validationport  "10250"
validationport  "30000"
validationport  "32767"
EOF

### Disabling Swap Memory ###
sudo swapoff -a && sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo vi /etc/fstab

###Setting Up Unique Hostnames###
sudo hostnamectl set-hostname controlplane01
sudo hostnamectl set-hostname workernode01
sudo hostnamectl set-hostname workernode02

###Installing Docker Engine###
sudo apt update && sudo apt upgrade -y
sudo apt install ca-certificates curl gnupg lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo systemctl start docker && sudo systemctl enable docker 
sudo systemctl status docker

### Configuring Cgroup Driver ###

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo systemctl daemon-reload && sudo systemctl restart docker

kubectl edit cm kubelet-config -n kube-system
cgroupDriver: systemd



### Update the cgroup driver on all nodes ###
kubectl drain <node-name> --ignore-daemonsets
systemctl stop kubelet

Modify the container runtime cgroup driver to systemd
Set cgroupDriver: systemd in /var/lib/kubelet/config.yaml
systemctl start kubelet
kubectl uncordon <node-name>


### Installing kubeadm, kubelet, and kubectl ###

sudo apt install -y vim git bash-completion

    sudo apt install bash-completion
    sudo apt install git
    sudo apt install vim


sudo apt-get update
sudo apt update && sudo apt upgrade -y
sudo apt-get install -y apt-transport-https ca-certificates curl  ## sudo apt install apt-transport-https

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

## sudo apt install -y kubelet=1.23.1-00 kubectl=1.23.1-00 kubeadm=1.23.1-00

### Initializing the Control-Plane Node ###
sudo kubeadm init --apiserver-advertise-address=192.168.0.2 --apiserver-cert-extra-sans=192.168.0.2 --pod-network-cidr=10.0.0.0/16 --node-name controlplane01

### Error code = Unimplemented desc = unknown service runtime.v1alpha2.RuntimeService ###
sudo rm /etc/containerd/config.toml
systemctl restart containerd
kubeadm init ...

### Configuring kubectl ##
mkdir -p $HOME/.kube \
&& sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config \
&& sudo chown $(id -u):$(id -g) $HOME/.kube/config

#or#

export KUBECONFIG=/etc/kubernetes/admin.conf

### Installing Calico CNI ### 
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

kubectl get nodes
kubectl get pods --all-namespaces

************************************
## Setting Up the Worker Node ###
************************************
# from the controlplane node
kubeadm token create --print-join-command

sudo kubeadm join 192.168.0.2:6443 --token atxxu3.wsc9vsn41i0wgj7k --discovery-token-ca-cert-hash sha256:14f57f54b81a040bccf543f1021f54bef18d9b103320ca2e65148b92c97f86d7
kubectl get nodes

### CNI - the Container Network Interface ###
#controlplane weave
kubectl apply -f https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')

### Testing the Cluster by Running an Application ###
kubectl create ns yelb
kubectl config set-context --current --namespace=yelb
kubectl apply -f https://raw.githubusercontent.com/lamw/vmware-k8s-app-demo/master/yelb.yaml
kubectl get pods
kubectl -n yelb describe pod $(kubectl -n yelb get pods | grep yelb-ui | awk '{print $1}') | grep "Node:"

### show website ###
http://74.207.224.192:30001


kubectl cluster-info
kubectl config -h
kubectl cluster-info dump


kubectl auth can-i create deployments
kubectl auth can-i create deployments --as linda
kubectl auth can-i create deployments --namespace secret

kubectl api-resources | less
kubectl explain event
kubectl explain pod
kubectl explain pod.spec.containers | less
kubectl api-versions
kubectl explain deployments.spec.strategy
kubectl explain deployments.spec.strategy.rollingUpdate

## Enabling Shell Autocompletion
sudo apt install bash-completion
kubectl completion bash
kubectl completion bash >> ~/.bashrc


sudo -i
kubectl completion bash > /etc/bash_completion.d/kubectl

#curl
kubectl proxy --port=8001 &
curl http://localhost:8001/version
curl http://localhost:8001/api/v1/namespaces/default/pods

#Delete from curl
curl -XDELETE http://localhost:8001/api/v1/namespaces/default/pods/busybox2

##Interrogate and manage etcdctl database
etcdctl
sudo apt install etcd-client
etcdctl -h

ETCDCTL_API=3 etcdctl -h


curl http://localhost:8001/api/v1/namespaces/kube-system/pods
ps aux |grep etcd

## Namespaces
kubectl get ns
kubectl get all --all-namespaces

kubectl create ns dev
kubectl describe ns dev
kubectl get ns dev -o yaml

##deployments
kubectl delete replicasets.apps newnginx-689d66cffc
kubectl delete deployments.apps -n kubernetes-dashboard dashboard-metrics-scraper kubernetes-dashboard

kubectl get deployments.apps newnginx -o yaml
kubectl get deployments
kubectl scale deployment newnginx --replicas=3
kubectl edit deployments.apps newnginx

#Dashboard
https://github.com/kubernetes/dashboard
https://github.com/kubernetes/dashboard/blob/master/docs/user/accessing-dashboard/README.md
kubectl cluster-info

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml
kubectl proxy


kubectl run billingapp --image=sotobotero/udemy-devops:0.0.1 --port=80 80
kubectl expose pod billingapp --type=LoadBalancer --port=8080 --target-port=80

#label
kubectl get deployments
kubectl get deployments --show-labels
kubectl label deployments.apps newnginx state=demo
#filter selector
kubectl get deployments.apps --selector state=demo
kubectl get all --selector app=newnginx

#rollout
kubectl run ngnix --image=nginx --replicas=3
kubectl rollout history deployment
kubectl edit deployments.apps rollingupdate
kubectl rollout history deployment rollingupdate --revision=2
kubectl rollout undo deployment rollingupdate --to-revision=1

kubectl create -f init_container.yaml
kubectl expose deployment newnginx --port=80 --name=myservice

#Daemonset
kubectl create -f fluentd-daemonset-elasticsearch.yaml
kubectl get daemonsets.apps -n kube-system
kubectl get pods -n kube-system


#Dashboard Kubernetes
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml
kubectl proxy
kubectl -it exec sharedvolume /bin/bash
  touch /centos1/test.log
kubectl exec -it sharedvolume -c centos2 /bin/bash
kubectl exec -it sharedvolume -c centos2 -- ls /centos2

kubectl explain pods.spec.volumes | less


apiVersion: v1
kind: Pod
metadata:
  name: sharedvolume
spec:
  containers:
  - name: centos1
    image: centos:7
    command:
      - sleep
      - "3600"
    volumeMounts:
      - mountPath: /centos1
        name: test
  - name: centos2
    image: centos:7
    command:
      - sleep
      - "3600"
    volumeMounts:
      - mountPath: /centos2
        name: test	  
  volumes:
   - name: test
     emptyDir: {}


### PV
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-volume
  labels:
    type: local
spec:
  capacity:
	storage:1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
	path: "/mydata"

kubectl create -f pv.yaml
kubectl get pv pv-volume
kubectl explain pv.spec.storageClassName


### nfs

apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nfs
spec:
  capacity:
    storage: 250Mi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
	path: /data
	server: myserver
	readonly: false

kubectl create -f nfs.yaml


### pvc
kubectl create -f pvc.yaml

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pv-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi

kubectl get pvc -o wide


### pv-pod

apiVersion: v1
kind: Pod
metadata:
  name: task-pv-pod
spec:
  volumes:
    - name: task-pv-storage
      persistentVolumeClaim:
        claimName: task-pv-claim
  containers:
    - name: task-pv-container
      image: nginx
      ports:
        - containerPort: 80
          name: "http-server"
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: task-pv-storage

##pv-pod
https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/

kubectl create -f pv-pod.yaml

#Storage Class
kubectl get sc
kubectl get sc -o yaml



### ConfigMap  and secrets
kubectl create cm nginx-cm --from-file ngnix-custom-config.conf
kubectl get cm
kubectl get cm nginx-cm -o yaml

server {
	listen 8888;
	server_name localhost;
	location / {
		root /usr/share/nginx/html;
		index index.html index.htm;
	}
}

#Secrets
  #encrypt
  echo -n "postgres" | base64
    cG9zdGdyZXM=
  
  #Decrypt
  echo "cG9zdGdyZXM=" | base64 -d
      postgres
  echo "cWF6cGxtMTIz=" | base64 -d
      qazplm123

kubectl apply -f secret-dev.yaml
kubectl apply -f secret-pgadmin.yaml
  kubectl get secrets
  kubectl describe secrets pgadmin-secret

kubectl apply -f configmap-postgres.yaml
  kubectl get configmaps
  kubectl describe configmaps postgres-init-script-configmap

kubectl apply -f persistence-volume.yaml
  kubectl get persistentvolume
kubectl apply -f persistence-volume-claim.yaml
  kubectl get persistentvolumeclaims

kubectl apply -f deployment-postgres.yaml
kubectl apply -f deployment-pgadmin.yaml

kubectl apply -f .\service-postgres.yaml
kubectl apply -f .\service-pgadmin.yaml

#delete all for specific path
kubectl delete -f ./

kubectl apply -f ./