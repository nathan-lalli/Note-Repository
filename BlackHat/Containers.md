
## Kubernetes

* Kubernetes is a portable, extensible, open-source platform for managing containerized workloads and services, that facilitates both declarative configuration and automation.
* Kubernetes is an open-source project written in the Go language.
* Kubernetes was started by Google as Borg (2004) and donated to the Cloud Native Computing Foundation (CNCF) in 2015.
* Generally, Kubernetes has new releases every three months.

![[Pasted image 20240805160955.png]]

**Basics**

* Pod - A group of containers, co-located on the same host
* Labels - Labels for identifying pods
* Kubelet - Container agent
* Proxy - A load balancer for pods
* etcd - Metadata service (key-value store)
* Replication Controller - Manage replication of pods

**Controller Node**

* kube-apiserver
	* The Kubernetes API server validates and configures data for the API objects like pods, services etc. and acts as a frontend to the cluster's shared state through which all other components interact.
* etcd
	* Consistent and highly-available key value store used as Kubernetes' backing store for all cluster data.
* kube-schedular
	* Assigns node for the newly created pods.
* kube-controller-manager
	* Controls the state of the cluster. Logically, controllers are separate processes but are compiled in a single binary.
* cloud-controller-manager
	* The cloud controller manager lets you link your cluster to your cloud provider's API.

**Worker Node Components**

* kubelet
	* kubelet is an agent that runs on each node in the cluster. It makes sure that containers are running in a Pod.
* kube-proxy
	* kube-proxy is a network proxy that runs on each node in your cluster. kube-proxy maintains network rules on nodes. These network rules allow network communication to your Pods from network sessions inside or outside of your cluster.
* container runtime
	* The container runtime is the software that is responsible for running containers on each node.

**Security Overview**

* Didn’t have any security by default for versions 1.5 and below
* Kubernetes added RBAC & ABAC models version >=1.5.
* By default, if not mentioned, all things run as root in the container.
* Access to etcd is open by default.
* Lots of security misconfigurations.

**Kubernetes Ports**

![[Pasted image 20240805161337.png]]

### Kubectl

* The kubectl command-line tool lets you control Kubernetes clusters.
* For configuration, kubectl looks for a file named config in the $HOME/.kube directory.
* You can specify other kubeconfig files by setting the KUBECONFIG environment variable or by setting the --kubeconfig flag.
* Kubectl examples
	* kubectl run --image=\<image-name\>
	* kubectl get pod
	* kubectl describe pod \<pod-name\>
	* kubectl apply –f \<deployment-file.yaml\>

**Tricks**

* Create your own kube node
	* kubectl create -f test.yml
* Execute code or run shell from a specific contianer
	* kubectl exec \<pod-name\> -c \<container-name\> -i -t -- \<shell\>
* Copiers to and from nodes
	* kubectl cp \<some-namespace\>/\<some-pod\>:/tmp/foo /tmp/bar

**Enumeration**

* List Kubernetes details
	* kubectl cluster-info
* List all the resources
	* kubectl get all || (pods, namespaces, services)
* Prints all information about the individual pod|service|deployment
	* kubectl describe pod|service|deployment \<name\>
* Runs a nginx as deployment
	* kubectl run nginx --image=nginx
* Creates a Kubernetes resource based on the file configuration
	* kubectl create -f ./input_file.yaml

>Practice environment available at: https://kubernetes.io/docs/tutorials/kubernetes-basics/create-cluster/cluster-interactive/

### Attacking Kubernetes

* Kubernetes Exposer
	* External
		* Controller node, Nodes, Apps
	* Internal
		* Service accounts, Pod network, Service network, Volumes, Configs & Secrets, env variables
	* Cloud Environment
		* Metadata APIs, IAM privileges, Container Registries, Storage, etc.

**Attack Service**

* Identify current users in the pod. root == system compromised chances.
* Identify various services exposed on the network/localhost.
	* 10250 : API (kubelet exploit)
	* API Read/write access == full pwnage
* Identify a list of running pods using API.
	* curl –sk https://192.168.99.101:10250/runningpods/ | python –mjson.tool
* Identify if the token is accessible.
	* /var/run/secrets/kuberenetes.io/serviceaccount/token 
* Token/API gives direct access to interact with the Base Machine.

**Attacking Externally Exposed Infrastructure**

* Exposed Applications
	* Applications vulnerable to remote code execution
	* Management and Monitoring Applications
		* cAdvisor-Matrices, dashboard
			* curl \<cluster-ip\>:10249/metrics

**Attacking Internal Infrastructure**

* Pods
	* Service account privilege enumeration
	* Kernel exploits
	* Container security configuration
	* Sensitive data exposure
* Network
	* Ports exposed on Pod Network
	* Ports exposed on Service Network
* Other Targets
	* Configs, Secrets, Volumes, Environment Variables and Vulnerable versions of Kubernetes components.

**Attacking Pods**

* Enumerating privileges available to the service account mounted in the pod