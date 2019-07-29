# Kubernetes Complex Fibonacci

Multi-container app with Kubernetes production ready with Google Cloud

## Why Google Cloud?

* Google created Kubernetes
* Good docs for beginners

## Start with a new project on [cloud.google.com](https://console.cloud.google.com)

After creating new project, go to menu:Compute:Kubernetes Engine:Create cluster.

## Travis deployment script

Add travis deployment script to repo (```.travis.yml``` config file) with the following content:

### Install Google Cloud SDK CLI

Add to travis ```before_install```:

    - curl https://sdk.cloud.google.com | bash > /dev/null; # download and install sdk in travis CLI
    - source $HOME/google-cloud-sdk/path.bash.inc

### Configure the SDK with our Google Cloud auth info

#### Generate ```service-account.json``` credentials file

1. On Google Cloud console create a Service Account and download service account in a json file. It is a sensitive file. Do not commit that file.

    Menu:IAM & Admin:Service Accounts:Create Service Account with name ```travis-deployer``` (it is an example name).
    Choose Role:Kubernetes Engine:Kubernetes Engine Admin (Full management of Kubernetes Clusters and their Kubernetes API objects.)
    Create and download private key (choose JSON format).

2. Download and install the Travis CI CLI

    * Install locally from [github.com/travis-ci/travis.rb](https://github.com/travis-ci/travis.rb)

    or

    * Get a docker image with ruby pre-installed and install Travis CI CLI there

      Run a container and map a volume in it so we have access to Service Account json file so we can encrypt it with travis tools. Then open shell and install travis there:

          docker run -it -v $(pwd):/app ruby:2.3 sh

      Change into ```/app``` directory, where our current project should be, then

          gem install travis -v 1.8.10 --no-document
          gem install travis
          travis login

3. Encrypt and upload the json file to our Travis account

    Copy generated json file (let's name it ```service-account.json```) into volumed directory so we can use it in the container then encrypt it and tie into your repo:

        travis encrypt-file service-account.json -r nataliastanko/KubernetesComplexFibonacci

    You will get ```service-account.json.enc``` file. Make sure to add it to the git repository.

4. In ```travis.yml``` add code to unencrypt the json file and load it into Google Cloud SKD

    Add the following to your build script (before_install stage in your  ```.travis.yml```, for instance):

        openssl aes-256-.......

    Make sure not to add ```service-account.json``` to the git repository. Just delete the file.

Establish your GC:
* real project name (ID displayed on project list)
* compute zone (menu:Compute:Kubernetes Engine:Location)
* cluster name (menu:Compute:Kubernetes Engine:name)

and put it into ```.travis.yml```.

### Login to Docker CLI

With adding to ```.travis.yml```:

    - echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

And to your [travis](https://travis-ci.org) project Settings:Environment Variables add ```DOCKER_PASSWORD``` and ```DOCKER_USERNAME``` with your docker credentials.

### Build the test version image and run tests

  Tag a new image version for tests and run them.

### If tests are successful run a script to deploy newest image

Create ```deploy.sh``` deploy script and run it ```./deploy.sh``` with travis.

### Build all our images, tag each one, push each to docker hub

With ```deploy.sh``` script build an image for client, server and worker, apply all configs in the k8s folder.

### Imperatively set latest images on each deployment with ```deploy.sh``` script

We have to tag it with both latest and unique version tags (2 tags) so the images are pulled. Let's use git commit SHA.

## Configuration on Google Cloud panel

### Create a secret var manually on remote kubernetes instance.

Use GC dashboard -> Activate Cloud Shell shortcut and rerun series of commands:

    gcloud config set project multi-k8s-248118 # it is your GC project ID
    gcloud config set compute/zone europe-west3-a
    gcloud container clusters get-credentials multi-cluster # it is your GC cluster name
    kubectl create secret generic pgpassword --from-literal PGPASSWORD=yourpassword # this password can be different than your prev dev env app password

You can preview list of secrets on menu:Compute:Kubernetes Engine:Configuration

### Configure Ingress Service

* Use [ingress-nginx][Kubernetes ingress-nginx repo].
* On [NGINX Ingress Controller for Kubernetes installation guide](https://kubernetes.github.io/ingress-nginx/deploy) choose Using [Helm][Kubernetes Using Helm].

#### Helm (client)

[Helm](https://helm.sh) is a package manager for Kubernetes ([github](https://github.com/helm/helm), [installation guide from script](https://helm.sh/docs/using_helm/#from-script)). Install it via google cloud console (```curl -L https://git.io/get_helm.sh | bash```).

#### GKE on Google Cloud

[Helm GKE](https://helm.sh/docs/using_helm/#gke)

##### RBAC - Role Based Access Control

* Who can access and modify objects in our cluster
* Enabled on Google Cloud by default

Tiller wants to make changes to our cluster so it needs to get some permissions set.

* User Accounts - identifies a person administering our cluster
* Service Accounts - identifies a pod administering a cluster
* ClusterRoleBinding - authorizes an account to do a certain set of actions across the entire cluster
* RoleBinding - authorizes an account to do a certain set of actions in a single namespace

    kubectl get namespaces

Create a new service account called tiller in the kube-system namespace:

    kubectl create serviceaccount --namespace kube-system tiller

Create a new cluserrolebinding with the role cluser-admin and assign it to service account tiller:

    kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluser-admin --serviceaccount=kube-system:tiller

###### Troubleshooting

If you get the error ```Error: release my-nginx failed: namespaces "default" is forbidden: User "system:serviceaccount:kube-system:tiller" cannot get resource "namespaces" in API group "" in the namespace "default"``` fix it with solution from [this link](https://docs.bitnami.com/kubernetes/how-to/configure-rbac-in-your-kubernetes-cluster/#use-case-2-enable-helm-in-your-cluster).

Create a ```tiller-clusterrolebinding.yaml``` file with the following contents:

```yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: tiller-clusterrolebinding
subjects:
- kind: ServiceAccount
  name: tiller
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: ""
```

and deploy the ClusterRoleBinding:

    kubectl create -f tiller-clusterrolebinding.yaml

#### Initialize Helm

    helm init --service-account tiller --upgrade

Kubernetes cluster has RBAC enabled ([Kubernetes Helm doc][Kubernetes Using Helm]) so run:

    helm install stable/nginx-ingress --name my-nginx --set rbac.create=true

to create a set of objects.

Go to Workloads tab to se your deployments:

```
my-nginx-nginx-ingress-controller	 OK	Deployment	1/1	default	multi-cluster
my-nginx-nginx-ingress-default-backend	 OK	Deployment	1/1	default	multi-cluster
```

Go to Services (Services & Ingress) tab and look at Endpoints. Click on one and see ```default backend - 404``` message.

Go to menu:Networking:Network services to see Google Cloud LoadBalancer.= created for our cluster. It's details say there are 3 instances of VM nodes of kubernetes cluster.

#### Tiller (the Helm server)

Server that modifies kubernetes cluster

## Deploy

[Kubernetes ingress-nginx repo]: http://github.com/kubernetes/ingress-nginx
[Kubernetes Using Helm]: https://kubernetes.github.io/ingress-nginx/deploy/#using-helm

***

***

***

* Based on [udemy course](https://www.udemy.com/docker-and-kubernetes-the-complete-guide/).