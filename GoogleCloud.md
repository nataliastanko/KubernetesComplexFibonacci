# Kubernetes Complex Fibonacci

Multi-container app with Kubernetes production ready with Google Cloud

## Why Google Cloud?

* Google created Kubernetes
* Good docs for beginners

## Start with a new project on [cloud.google.com](https://console.cloud.google.com)

After creating new project, go to menu:Compute:Kubernetes Engine:Create cluster.

## Travis deployment script

Add travis deployment script to repo (```.travis.yml``` config file) with the following content:

1. Install Google Cloud SDK CLI
2. Configure the SDK with our Google Cloud auth info
3. Login to Docker CLI
4. Build the test version
5. Run tests
6. If test are successful run a script to deploy newest image
7. Build all our images, tag each one, push each to docker hub
8. Apply all configs in the k8x folder
9. Imperatively set latest images on each deployment


### Generate ```service-account.json``` credentials file

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

  Add the following to your build script (before_install stage in your .travis.yml, for instance):

4. In ```travis.yml``` add code to unencrypt the json file and load it into Google Cloud SKD

      openssl aes-256-.......

  Make sure not to add ```service-account.json``` to the git repository. Just delete the file.

***

***

***

* Based on [udemy course](https://www.udemy.com/docker-and-kubernetes-the-complete-guide/).