---
tags:
  - ctf
  - aws
  - CloudTrail
difficulty: easy
category: cloud
---
# Challenge

Elric Ashspar finds a seizure stamp in a dead clerk's bag near Stonepass. Vaultrune uses copies of that stamp to take supplies from Sythra's border guards, leaving a road Stormbound needs open without them. The stamp looks old, but Elric spots fresh tool marks on it. He must find the flaw, prove the stamp is fake, and give the guards a quick way to reject future copies.

Stonepass's surviving CloudTrail history is the only record of activity surrounding the copied stamp. You hold read-only investigator access. Reconstruct the final recorded actions and determine which identity stopped the trail from logging.

## 8 Questions

  
1. What was the last CloudTrail API action performed by the compromised user from the internal IP immediately before the attacker session began?
2. What was the first CloudTrail API action called from the attacker IP?
3. Which API action did the attacker attempt that was explicitly denied before the trail was stopped?
4. Which S3 bucket did the attacker enumerate before stopping the trail?
5. What is the name of the CloudTrail trail that was stopped?
6. Which IAM username's credentials were used to execute the trail disable?
7. From which IP address was the trail disabled?
8. Which API action was used to disable the audit trail?

## Initial Credentials 

```creds
export AWS_ENDPOINT_URL=http://<challenge-ip>:<aws-port>
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCESS_KEY_ID=AKIAJB77JYJNCUJ8IV3O
export AWS_SECRET_ACCESS_KEY=YsMZU0Wrj2u0LQlOFaVtkQNX3VuKyWH/oyIoZqun
unset AWS_SESSION_TOKEN
```

## Recon

The question mentions CloudTrail, this is an AWS service that tracks user activity and API calls in your AWS account to help with governance, compliance, and security audits.

Using the CLI I was able to perform a lookup of events in the logs with the following command:

```bash
aws cloudtrail lookup-events
```

I used `tee` to output this all to a file and then used JQ to parse it in a more readable format.

```bash
aws cloudtrail lookup-events | tee lookup_events.json
```

```bash
jq .Events[] lookup_events.json
```

Search for the key word `denied`, I was able to start the trail and find the rest of the answers to all of the questions by following the IP that was different than the rest of the IPs in the log.

## Lessons Learned

AWS CloudTrail is a tool that exists and is good for logging and alerting/defending.
There are ways to bypass it sometimes, but there is almost always a trail.