
## What is a Cloud?

* Shared **pool of configurable** system resources
* Decentralized
* Rapid provisioning
* Remote access
* Minimum management
* Reduced IT hardware upfront cost
* Flexible and scalable
* Can be:
	* Public
	* Private
	* Hybrid
	* Community

### Types of Cloud Services

![Pasted image 20240806114506](../Images/Blackhat/Pasted%20image%2020240806114506.png)

### Shared Responsibility Model

![Pasted image 20240806114541](../Images/Blackhat/Pasted%20image%2020240806114541.png)

### Why Cloud Security Matters

* Major push by organization to be on cloud or cloud native
* Multitude of offerings === different threat models
* Misconfigurations can increase threats
* Lapse in security can cause money/data/resource losses
* Examples:
	* [ Cryptojacking in cloud ](https://www.helpnetsecurity.com/2018/05/16/cloud-cryptojacking)
	* [Code Spaces closed their shops because of AWS creds theft](https://www.csoonline.com/article/2365062/code-spaces-forced-to-close-its-doors-after-security-incident.html)

### Infra Security

![Pasted image 20240806114932](../Images/Blackhat/Pasted%20image%2020240806114932.png)

### Conventional Infra vs Cloud Offerings

![Pasted image 20240806115034](../Images/Blackhat/Pasted%20image%2020240806115034.png)

### Traditional Infra vs Cloud Mapping

![Pasted image 20240806115058](../Images/Blackhat/Pasted%20image%2020240806115058.png)

## Enumeration

| Asset Enumeration                                                                                                                                       | Credential Hunting                                                                                                                                  |
| ------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| Subdomains<br>	Target Domain<br>	SaaS Service Providers<br>OSINT<br>	Search Engines<br>		Google<br>		Shodan<br>		Bing<br>	Certificate Transparency Logs | Username Enumeration<br>	AWS Cloud APIs<br>	Azure Cloud APIs<br>OSINT<br>	Code Repositories<br>		GitHub<br>		Bitbucket<br>		etc.<br>	Google Dorking |

### Enumerating for Cloud Assets: DNS

**DNS Records can reveal a lot of information**

* **MX** can point to various filtering or hosted email solutions
* **NS** records can point to DNS protections
* **TXT** records are used generally for domain validation
	* **SPF** record lists various authorized entities for sending emails
		* SaaS Providers
		* VM or IPs controlled by organizations

### Enumerating via Subdomains

**Its customary to link SaaS provider URLs to your primary domain vis CNAME pointing of Subdomain**

* A quick DNS query for common subdomains like Helpdesk or blog would give good results
* Beware of subdomain takeover issues in this scenario

### Enumerating vis SaaS Provider Subdomains

* We can do a lookup against third-party domains using common patterns to see if anything is registered
* This is not 100% accurate and may yield mixed results
* Not all SaaS providers will give you a dedicated subdomain and org may not have linked all its SaaS solutions with subdomains

### Cloud Enumeration Tools

#### DNS Scan

* Wordlist based DNS Scanner [dnsscan](https://github.com/rbsec/dnscan)

![Pasted image 20240806121929](../Images/Blackhat/Pasted%20image%2020240806121929.png)

#### Cloud Enum

* [cloud_enum](https://github.com/initstring/cloud_enum)

![Pasted image 20240806122033](../Images/Blackhat/Pasted%20image%2020240806122033.png)

#### Google Dorking for Cloud

* Cloud uses predefined subdomains which helps an attacker to quickly identify resources
	*  *Example: *.azureedge.net, *.core.windows.net, *.appspot.com, *.s3.amazonaws.com, *.cloudfunctions.net. *.azure-api.net
* In cloud platform, it could be easy to identify misconfigured cloud services using Google dorks
	* Examples:
		* *site: *.s3.amazonaws.com + example.com
		* *site: *.s3-website-us-west-2.amazonaws.com (static website)

#### Certificate Transparency Log Search Engines

* crt.sh
* censys.io

![Pasted image 20240806122727](../Images/Blackhat/Pasted%20image%2020240806122727.png)

## Cloud Service Attack Services

### Understanding Data and Control Plane

* Cloud computing platforms can be divided into to planes
* Control plane
	* Management interfaces (Cloud Web Consoles)
	* Cloud APIs access (API KEY)
	* Command line interfaces
	* Container images (K8s or similar)
* Data plane
	* Consumer cloud component

#### Which Plane to Hack: Data or Control

* Data plane would generally be the entry point
* Data plane if you want to access data
* Control plane if you want to gain full control of the environment
* Control plane hacks would mostly be due to leaked keys

## Connecting to Cloud Environment

* Cloud service providers expose APIs to connect with them
* These APIs are generally REST based
* As these APIs are complex; vendors have created CLIs
* Cloud CLIs are in multiple languages
	* Python
	* PowerShell
	* etc.
* Most projects would be in these 2 languages

## Metadata API

* API layer provided by all cloud providers for system and environment information
* All cloud service providers give this facility, however, features and formats vary significantly
* Generally accessible from within services over non-routable IP Address 169.254.169.254
	* Responds to HTTP requests
	* Cascaded folder style content arrangement
	* May require some extra headers

### Metadata API: AWS

* The AWS Metadata API solution is the most “complete”
* Especially useful if the environment is using IAM Profiles
* IAM Profiles allow you to club together various services and capabilities within a single profile
* If you have access to IAM profile credentials you can get "evil"
* If Machine has an IAM Profile attached, we may obtain temporary creds via Metadata API

#### Metadata API: AWS Obtaining Creds

**Obtaining Temporary Security Credentials**

* IMDSv1

```bash
curl http://169.254.169.254/latest/meta-data/iam/security-credentials/role_Name
```

* IMDSv2
* Requires a mandatory header with all requests

```bash
TOKEN=`curl -X PUT "http://169.254.169.254/api/token" -H "X-aws-ec2-metadata-tokenttl-seconds: 21600"` 
curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/metadata/iam/security-credentials/role_Name
```

### Metadata API: GCP

* Mandatory header for all requests
	* Metadata-Flavor: Google
* Obtain Service Account Token
	* http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token
* Other interesting URL
	* http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=true&alt=json
	* http://metadata.google.internal/computeMetadata/v1/instance/attributes/kube-env

### Metadata API: Azure

* API Requires mandatory header for all requests
	* Metadata: true
* Obtain service account token
	* http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=APP_URL

## Understanding the Attack Surfaces
### Understanding the Attack Surfaces: SaaS

* Cloud Service provider maintains all the stack
* Attack Surface is like web applications
* OWASP Web Application testing guide is a great place to start
* Issues will be specific to services in nature
* Responsibilities
	* Tenant: Data and Access Management
	* Provider: Everything besides data and access

#### SaaS Specific Attacks: Subdomain Takeover

* When 3rd part services allow domain integration via CNAME
* CNAME entry is created pointing to 3rd party domain, usually a CDN subdomain
* If CNAME entry exists but 3rd party section is not claimed/expired/cancelled
* The trust can be abused to takeover the subdomain
* This is useful to
	* Prove ownership of a resurce
	* Hijack domain level resources including domain cookies

### Understanding the Attack Surfaces: FaaS

* A.K.A: "Serverless" Computing
* To be clear- **Serverless** is not without Server
* It is where you don't have to worry about the server at all
* One service, multiple names
	* AWS Lambda
	* Azure Functions
	* GCP Cloud Function
	* Apache OpenWhisk
* You write a **single function** (multi language support) and service provider invokes it when a request comes
* The **application logic** is executed in a containerized environment which is later destroyed
* Data is not managed by FaaS
* Pay only for computation power used for processing

#### FaaS: Flow

![Pasted image 20240806145223](../Images/Blackhat/Pasted%20image%2020240806145223.png)

**Trigger**: Any event which can be integrated as a trigger for f(x)
**Action**: Result of the f(x) could be a call to another f(x) or API

#### FaaS: Attack Surface and Caveats

* Function execution has timeouts
	* 3 seconds in general, but can be max of 15 minutes or more
* **Once execution** is done next execution could be on a different environment all together
* Container specific **attacks could be applicable**
* AWS Lambda doesn't have access to metadata API
	* But does have access tokens in environment variables
* Serverless Top 10 : https://github.com/puresec/sas-top-10

#### FaaS Practice Environment

* https://github.com/we45/DVFaaS-Damn-Vulnerable-Functions-as-a-Service
* https://github.com/puresec/Serverless-Goat
* https://github.com/torque59/AWS-Vulnerable-Lambda

#### Post Access Enumeration

**After successful extraction of token(s), we need to enumerate**
* What services are accessible to users
* What IAM capabilities are available
* Services entities available (S3 buckets, EC2 instances, Snapshots, etc.)

**Audit software are made with high privilege in mind**
* Pentesters need easier approach to enumerate these permissions
* NotSoSecure has built a suite of pentester focused scripts to enumerate aws/azure/gcp cloud environments

### Understanding the Attack Surfaces: PaaS

* Access to **provider-maintained** platform directly
* Example: Heroku, S3, app engine, IIS Azure
* Less flexible than IaaS but still gives more control then FaaS or SaaS
	* Like shared hosting environments
* Service provider can restrict Runtimes
* Responsibilities
	* Tenant: Focus on application and logic entities
	* Provider: Takes care of stack from till Runtime
* Attack surface:
	* Application logic bugs
	* Platform specific focused bugs

#### PaaS: Cloud Storage

* Cloud Storage is an example of **Platform as a Service**
* All the major providers offer a service in this category
	* AWS: Simple Storage Service (S3)
	* Azure: Azure storage
	* GCP: Google Cloud Storage
* Data is stored in blobs such as JSON objects
* May allow static website hosting
* Storage names generally are unique for the cloud service provider
* Storage names generally **follow a pattern** and can be enumerated
* 3 common modes
	* World accessible
	* Authenticated access
	* Restricted to specific id
* List/Write objects will allow people to fetch or write contents to folders

##### Cloud Storage: Attack Surface

* The major issues in cloud storage are around improper permissions
* World read
* write access for a resource
* Restricted to authenticated users
* Lax IAM Rules/Policies giving access to data

##### AWS Storage Buckets

* Access AWS buckets
	* https://s3.amazonaws.com/bucket_name
	* https://bucketname.s3.amazonaws.com
* Bucket enumeration possible via difference in error messages
* For REST style URL we now need region tagged
	* https://s3.region.amazonaws.com/bucket_name
* Identify region of bucket
	* Request to any random region URL will reveal correct URL
		* https://s3.anyregion.amazonaws.com/bucket_name

###### AWS Storage Buckets: Tools

* S3Scanner
* Bucket-stream
* CloudScraper
* S3-inspector
* Buckets.grayhatwarefare.com

##### GCP Storage Buckets

* GCP storage buckets can be accessed by https://victimpublic.storage.googleapis.com/
* Open-source scripts available to search storage buckets.
	* Gsutil
	* GCPBucketBrute

##### Storage Attacks: Azure

* Azure storage can be accessed by 
	* https://storagename.blob.core.windows.net/container

```bash
az storage account check-name --name <storagename>
```

* Container content can be enumerated with brute force attack

```bash
curl -l https://<storagename>.blob.core.windows.net/<container>?restype=container
```

* MicroBurst tool can perform storage, blob, and service enumeration for Azure
* Azure storage account contains Blobs, Queues, Tables, and files (shared folder or drive) as storage types
* Azure allows creation of URLs with specific access to storage accounts

![Pasted image 20240806151546](../Images/Blackhat/Pasted%20image%2020240806151546.png)

### Understanding the Attack Surfaces: CaaS

* Container as a service
* Very useful for service-based architecture
* Bring your own container and run it in CaaS
* Docker or Kubernetes hosted environments
* **Examples**: ECS, EKS, ECR, GKE, AKS
* Responsibilities
	* Tenant: Focus on images, application, and logic entities
	* Provider: Takes care of stack till Middleware (docker/k8s)

#### CaaS: Attack Surface

* Docker image level issues
* Application logic bugs
* Platform specific focused bugs

### Understanding the Attack Surfaces: IaaS

* Direct control of virtual machine
* Functionally closest to on-premise solution
* Most flexible option with maximum control to tenant
* Responsibilities
	* Tenant: maintain & update the virtual machine OS & anything above
	* Provider: Everything below virtual machine

#### IaaS: Attack Surface

**Usual Attack Surface**
* Unpatched machines
* Shared/non-secured credentials
* Software/application flaws
* Misconfiguration (Firewall or other systems)
* Weak account passwords with predictable username

**Cloud Specific Attack Surface**
* Auth token stealing via metadata API

## Snapshots

* Provide a way to **save point-in-time** backup
* Can be **public or private**
* Public snapshots can be **cloned to another user account**
* New storage can be created via snapshots in account
* These storages can **reveal confidential information**
	* SAM database on Windows
	* /etc/shadow on Linux
	* Config files for various apps
* AWS:

```awscli
aws ec2 describe-snapshots --owner-id <get from get-caller-identity>
aws ec2 describe-snapshot -region <region>
```

* GCP:

```gcloud
gcloud compute snapshots list
```

