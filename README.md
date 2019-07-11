# Kubernetes Complex Fibonacci

Multi-container app withKubernetes production ready

#### Config file for each service and deployment

Create ```client-deployment.yaml``` for multi client deployment with 3 child pods running multi-client-fib image.

#### Services

Set up some networking for an object (single pod of a group of pods managed by Deployment).

##### Services: ClusterIP

ClusterIP is a subtype of Service object.
Restrictive type of networking.
Allows any other object in our cluster to access the object that the ClustrIP ponts at. But nobody else from the outside world (e.g. web browser) can access it. It does not allow traffic from the outside world.
Exposes a pod or a set of pods to other ojects in the cluster

Create ```client-cluster-ip-service.yaml``` to expose access to our set of multi-client-fib pods to every other object inside of our cluster.

Delete old deployment:

    kubectl get deployments
    kubectl delete deployment client-deployment
    kubectl get deployments
    kubectl get services
    kubectl delete services client-node-port
    kubectl get services # do not delete kubernetes service

Load the configfile into kubernetes.

    kubectl apply -f k8s/client-deployment.yaml

Or load a group of files inside of k8s

    kubectl apply -f k8s

##### Services: NodePort

NodePort is a subtype of Service object.
Exposes a set of pods to the outside world (only dev).

#### 1. Test localy on minikube

#### 2. Create github and travis flow to build images and deploy

#### 3. Deploy app to a cloud provider

### Ingress Service

Instead of Nginx we ar going to use Ingress Service for routing.
Request traffic goes through Ingress Service and it accessible in our cluster thanks to it.

### PVC - Persistent Volume Claim

***

***

***

* Based on [udemy course](https://www.udemy.com/docker-and-kubernetes-the-complete-guide/).