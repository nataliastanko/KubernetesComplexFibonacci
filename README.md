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

### PVC - Persistent Volume Claim

Not an actual volume. You can get it when pod is created. Created on the fly, dynamically, when you ask for it.

Create ```database-persistent-volume-claim.yaml```.

## Cloud storage provider examples

* Google Cloud Persistent Disk
* Azure File
* Azure Disc
* AWS Block Store

[Storage Classes options](https://kubernetes.io/docs/concepts/storage/storage-classes/)

## Ingress Service

Instead of Nginx we ar going to use Ingress Service for routing.
Request traffic goes through Ingress Service and it accessible in our cluster thanks to it.

***

***

***

* Based on [udemy course](https://www.udemy.com/docker-and-kubernetes-the-complete-guide/).