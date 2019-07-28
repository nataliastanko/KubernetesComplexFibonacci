# Kubernetes Complex Fibonacci

Multi-container app with Kubernetes production ready

## Workflow

#### 1. Test locally on minikube

#### 2. Create github and travis flow to build images and deploy

#### 3. Deploy app to a cloud provider

## Config file for each service and deployment

#### Configure client

Create ```client-deployment.yaml``` for multi client deployment with 3 child pods running multi-client-fib image.

#### Configure server

Create ```server-deployment.yaml``` for multi-server image set of pods with port 5000 accessible on the image that gets created inside of each of those pods.

#### Configure worker

Create ```worker-deployment.yaml```.

#### Configure Redis

Create ```worker-deployment.yaml```.

#### Configure Postgres

Create ```postgres-deployment.yaml```.

### Services

Set up some networking for an object (single pod of a group of pods managed by Deployment).

### Services: ClusterIP

ClusterIP is a subtype of Service object.
Restrictive type of networking.
Allows any other object in our cluster to access the object that the ClusterIP points at. But nobody else from the outside world (e.g. web browser) can access it. It does not allow traffic from the outside world.
Exposes a pod or a set of pods to other objects in the cluster

#### Configure client

Create ```client-cluster-ip-service.yaml``` to expose access to our set of multi-client-fib pods to every other object inside of our cluster.

Delete old deployment:

    kubectl get deployments
    kubectl delete deployment client-deployment
    kubectl get deployments
    kubectl get services
    kubectl delete services client-node-port
    kubectl get services # do not delete kubernetes service

Load the config file into kubernetes.

    kubectl apply -f k8s/client-deployment.yaml

Or load a group of files inside of k8s

    kubectl apply -f k8s

#### Configure server

Create ```server-cluster-ip-service.yaml``` to provide access to multi server pods.

#### Configure Redis

Create ```redis-cluster-ip-service.yaml```.

#### Configure Postgres

Create ```postgres-cluster-ip-service.yaml```.

### Services: NodePort

NodePort is a subtype of Service object.
Exposes a set of pods to the outside world (only dev).

### Services: LoadBalancer

Legacy way of getting network traffic into a cluster. Allows access to one specific set of pods inside of an application.

## Services: Ingress

Instead of Nginx we ar going to use Ingress Service for routing.
Request traffic goes through Ingress Service and it accessible in our cluster thanks to it.

Ingress config is an object that has as a set of rules describing how traffic should be routed.

Ingress controller watches for changes to the ingress and updates traffic handling.

Deployment for multi-client is a type of controller which constantly works to make sure that routing rules are setup.

### Nginx Ingress

* [ingress-nginx][Kubernetes ingress-nginx repo] is a community led project (which we are going to use. Has already build-in some features like e.g. sticky session,
* [kubernetes-ingress](https://github.com/nginxinc/kubernetes-ingress) is a project led by the company nginx

### Setup ingress-nginx

#### On local machine

1. Go to [ingress-nginx][Kubernetes ingress-nginx repo], then follow the link at the top of repo and choose Deploy tab - [NGINX Ingress Controller for Kubernetes installation guide](https://kubernetes.github.io/ingress-nginx/deploy)
2. Choose Generic Deployment/Prerequisite Generic Deployment Command

	1. The following Mandatory Command is required for all deployments:

    		kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml

	2. Look at nginx-ingress-controller config Deployment object type (bottom of the [file][Kubernetes Nginx Ingress Controller])

3. Choose Provider Specific Steps:Minikube

	1. Run

			minikube addons enable ingress

4. Choose GCE-GK

 	1. Look at [GCE-GKE file](https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml)

    	There is LoadBalancer type of service.

5. Create ```ingress-service.yaml```

	and apply with

    	kubectl apply -f k8s

6. Use the result of

    	minikube ip

  	in your browser.

   If ```Your connection is not private``` proceed anyway.

#### On Google Cloud

## Combining Config into a single file

Config file ```server-config.yaml``` example:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: server-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      component: server
  template:
    metadata:
      labels:
        component: server
    spec:
      containers:
        - name: server
          image: nataliastanko/multi-server-fib
          ports:
            - containerPort: 5000
---
apiVersion: v1
kind: Service
metadata:
  name: client-cluster-ip-service
spec:
  type: ClusterIP
  selector:
    component: server
  ports:
    - port: 5000
      targetPort: 5000
```

* [example config file][Kubernetes Nginx Ingress Controller]

## Volumes

### What is volume

Volume in generic container terminology means some type if mechanism that allows a container to access a filesystem outside itself.

#### Volume in Kubernetes

Volume in Kubernetes is an object that allows a container to store data at the pod level. It is tied to pod's life cycle.

    kubectl get storageclass
    kubectl describe storageclass

### Volumes with databases

Postgres writes to a filesystem in a container. If a pod crashes it is going to be deleted by the deployment, we loose data and a new pod is going to be created with no data carrier over. Thats why we need volumes for Postgres in a host machine.

In case of data we want to last we need to use Persistent Volume or Persistent Volume Claim.

#### Replicas

Many databases connecting to the same volume (filesystem) without having them aware of each other is a disaster.

### PV - Persistent Volume

Long term durable storage volume not tied to any specific pod or container. Stays in its state when a pod crashes. Exists outside the pod. Volume existing already, is already available. Created ahead of time - statically provisioned.

    kubectl get pv

### PVC - Persistent Volume Claim

Not an actual volume. You can get it when pod is created. Created on the fly, dynamically, when you ask for it.

Create ```database-persistent-volume-claim.yaml```.

    kubectl get pvc

## Cloud storage provider examples

* Google Cloud Persistent Disk
* Azure File
* Azure Disc
* AWS Block Store

[Storage Classes options](https://kubernetes.io/docs/concepts/storage/storage-classes/)

## Environment variables

* REDIS_HOST - const values, it's URL
* REDIS_PORT - const values
* PGUSER - const values
* PGHOST - const values, it's URL
* PGDATABASE - const values
* PGPORT - const values
* PGPASSWORD - secret object in the cluster, created with imperative command on local machine:

      kubectl create secret generic secretname --from-literal key=value
      kubectl create secret generic pgpassword --from-literal PGPASSWORD=yourpassword
      kubectl get secrets


Or leave it empty and use the [link text itself].

URLs and URLs in angle brackets will automatically get turned into links.
http://www.example.com or <http://www.example.com> and sometimes
example.com (but not on Github, for example).

Some text to show that the reference links can follow later.

[Kubernetes Nginx Ingress Controller]: https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml

[Kubernetes ingress-nginx repo]: http://github.com/kubernetes/ingress-nginx

***

***

***

* Based on [udemy course](https://www.udemy.com/docker-and-kubernetes-the-complete-guide/).