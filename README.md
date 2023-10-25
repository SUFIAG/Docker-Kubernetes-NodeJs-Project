# Kubernetes Basics for Beginners with NodeJS Express Application

### What is Kubernetes?

Kubernetes is a orchestration tool for microservices.
It helps to scale the services according to the need of the users.

To manage the cloud native microservices we have to make sure some things

- Scale on demand
- Self-heal
- Support zero-downtime rolling updates
- Run anywhere

And Kubernetes provides all of them. It is called the OS of the cloud. What that means is you don't have to worry which service you are using underneath. This can be AWS or Linode. You can just swap out the underlying architecture if you use Kubernetes.

That's why it's so popular and powerful.

### Cluster and Nodes

A Kubernetes cluster is a collection of machines that have kubernetes installed. The machines can be a computer, a VM, a raspberry PI and so on.

We can install kubernetes on the machines and connecting them creates a Kubernetes cluster. And each of the machines are called Nodes

### Master and Worker

There are 2 kinds of nodes.

- Master nodes (Masters)
- Worker nodes (Nodes)

### Masters

Masters host the control pane and Nodes host user applications.
You want to maintain high availability for the master nodes.

### Workers

The Nodes (aka Workers) run 2 main services.

- Kubelet
- Container runtime

#### Kubelet

the **kubelet** is the main kubernetes agent. It communicates with the control pane.

Today we will learn how we can deploy a NodeJS application on a Kubernetes cluster. The steps are as follows

- Create a Docker Image for a NodeJS application
- Publish that Image to DockerHub
- Create a Linode Kubernetes Cluster
- Install Kubectl on our local machine
- Deploy our application into Kubernetes cluster

Let's begin!

### Create a Docker Image

In a previous article we learned how we can dockerize a basic NodeJS application.
You can find that article [here](https://www.mohammadfaisal.dev/blog/express-typescript-docker):

The repository for that article can be found [here](https://github.com/Mohammad-Faisal/express-typescript-docker)

So let's clone it first!

```sh
git clone https://github.com/Mohammad-Faisal/express-typescript-docker.git

cd express-typescript-docker
```

So we now have a NodeJS application that is already Dockerized!

### Publish an image on Dockerhub

Dockerhub is a place where you can publish your repositories. It's kind of Github for Docker images and it's free to use! So feel free to open an account [here](https://hub.docker.com/)

Then before we can publish the image we have to build it.

```sh
docker image build -t 56faisal/learn-kubernetes:1.0 .
```

Notice here,

```js
56faisal -> is the Dockerhub Username
learn-kubernets -> is the image name and
1.0 -> is the tag name
```


If you are running a Mac then your default Docker system will use **arm64** architecture. But on Linode your VM's are most likely built using **amd64** architecture. This version mismatch will cause problem when you deploy the image. So if you are on Mac build your image using the following command.

```sh
docker image build  --platform=linux/amd64 -t 56faisal/learn-kubernetes:1.0 .
```

Then see the image on the list locally.

```sh
docker image ls


REPOSITORY                                TAG                   IMAGE ID       CREATED        SIZE
56faisal/learn-kubernetes                 1.0                   13a974972901   2 hours ago    263MB
```

Then login to Dockerhub

```sh
docekr login --username docker_hub_id # for me it's 56faisal
```

It will ask for your password. give that and you should be good to go.

Then push the image to Dockerhub

```sh
docker image push 56faisal/learn-kubernetes:1.0
```

You can go to Dockerhub and verify that your image is there. For me the URL looks something like this:

```sh
https://hub.docker.com/repository/docker/56faisal/learn-kubernetes
```

### Let's Deploy!

But before we do that we need to install **kubernetes-cli**

```sh
brew install kubernetes-cli
```

You can get installation instructions for other OS [here](https://kubernetes.io/docs/tasks/tools/)

### Create Kubernetes Cluster on Linode

There are many kubernetes services but [Linode](https://cloud.linode.com/) offers the easiest way to manage them. So we will create a kubernetes cluster with 2 worker nodes on Linode.

I will not go into the details of that. you can [follow this link](https://www.linode.com/docs/guides/deploy-and-manage-a-cluster-with-linode-kubernetes-engine-a-tutorial/) to do that.

### Get the kubernetes cluster configuration

On your Linode kubernetes cluster page you will notice that there is a download button for your kubernetes config file.

Download that and put that into the root of the project. Or anywhere for that matter. This will allow us to interact with Kubernets cluster later on.

Open a terminal and save the kubeconfig's path to the **$KUBECONFIG** environment variable.

You can get the current directory path by running **pwd** and use that to get the path to your config file.

Let's set the context for us now!

```
export KUBECONFIG=/Users/mohammadfaisal/Documents/learning/express-typescript-docker/learn-kubernetes-kubeconfig.yml
```

Then run the following command to see the nodes! Nodes are physical machines or VM's that run on the cloud.

```sh
kubectl get nodes
```

We created 2 servers on our Linode cluster. So we will see 2 nodes.

```
NAME                          STATUS   ROLES    AGE   VERSION
lke55618-87276-6237a2503845   Ready    <none>   33m   v1.22.6
lke55618-87276-6237a2510769   Ready    <none>   33m   v1.22.6
```

The nodes are ready to run our applications.

### Create a deployment

So now we can interact with our kubernetes cluster.
But now we need to actually deploy something to understand it's power. Kubernetes has a concepts of pods. Pods are independent containers that run on your infrastructure.

You can create as many pods as you want and you can do that by configuring the deployment. What it means is you can have 20 pods on your 2 machines. And generally we have one container inside one pod.

Let's create a deployment configuration named **deployment.yml** and paste the following configuration there.

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: learn-kubernetes-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: express-docker-kubernetes
  template:
    metadata:
      labels:
        app: express-docker-kubernetes
    spec:
      containers:
      - name: express-docker-kubernetes
        image: 56faisal/learn-kubernetes:1.0
        ports:
        - containerPort: 3000
```

Here some of the important things to note are the following:

**selector** -> **matchLabels** -> **app** -> express-docker-kubernetes

This **app** helps us to name our pods. It will help us later to modify our deployments and relate it to services.

### Deploy your application

Then deploy this using the following command.

```sh
kubectl create -f deployment.yml
```

Here we are passing the **deployment.yml** file using the **-f** configuration. This allows us to create multiple deployment files for different folders.

You can see the deployments by running the following command:

```sh
kubectl get deployments
```

and this will give an output like this

```sh
NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
learn-kubernetes-deployment   0/2     2            0           7s
```

If you want to delete the deployment you can run the following command:

```sh
kubectl delete deploy learn-kubernetes-deployment
```

Here the last part is the name of the deployment

### See the pods

Your deployment has created 2 pods. Because we gave the option **replicas:2** in our deployment configuration.

Let's see those pods!

```sh
kubectl get pods
```

It will give you an output like this

```sh
NAME                                          READY   STATUS    RESTARTS   AGE
learn-kubernetes-deployment-6fdf4bf45-pglg8   1/1     Running   0          49m
learn-kubernetes-deployment-6fdf4bf45-s9dsd   1/1     Running   0          49m
```

So both of our pods are running! If you need to scale up all you need to do is just increase the number from 2 to whatever you want and re-deploy it.
It's that easy!

Sometimes you will need to see what's going on inside your pods. You can get more details from the pods using the following commands.

```sh
kubectl describe pods
```

The output will have all the information you will need. Including the IP addresses of the pods. But unfortunately you will not be able to access your application yet because your application is not exposed to the world yet!

Let's do that now!

### Show it to public

Let's expose the deployment to the world using the following command

```sh
kubectl expose deployment learn-kubernetes-deployment --type="LoadBalancer"
```

or else we can create a service for the deployment as well

```YAML
apiVersion: v1
kind: Service
metadata:
  name: learn-kubernetes-service
spec:
  selector:
    app: learn-kubernetes
  type: LoadBalancer
  ports:
  - protocol: TCP
    port: 3000
    targetPort: 3000
```

Then run

```sh
kubectl apply -f service.yml
```

And that will create a load balancer for our application on the linode server and we will get a public endpoint to call our service.

Once you successfully deploy the service get the details of the load balancer by running the following command:

```sh
kubectl get services
```

And you will see the following output:

```sh
NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)          AGE
kubernetes                 ClusterIP      10.128.0.1       <none>           443/TCP          4h58m
learn-kubernetes-service   LoadBalancer   10.128.247.181   172.105.44.102   3000:31752/TCP   74s
```

Notice the **EXTERNAL-IP** column which gives you the public IP address for your application.

Lets head over to your browser and hit the following URL

```sh
http://172.105.44.102:3000/
```

and you will be greeted with the following output.

```json
{ "message": "Hello World!" }
```

Our application is live now! And we can do whatever we want with it!

Congratulations on deploying your first NodeJS application using Kubernetes.
