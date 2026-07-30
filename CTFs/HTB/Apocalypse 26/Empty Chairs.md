---
tags:
  - ctf
  - aws
  - CloudTrail
difficulty: hard
category: cloud
---
# Challenge

Elowen Ashglass reaches one of Sythra's road watch posts after its morning signal fails. The fire pit is warm, spears lean by the door, and the scouts are gone. Red ash under the doorways and paired tracks on the road show that the Quiet Helpers took them alive. Without that post, Stormbound loses sight of the road ahead. Elowen must follow the tracks, find the missing scouts, and learn where the Helpers are taking them before frost covers the trail. The watch post's dispatch systems recorded activity before the scouts disappeared. You hold read-only investigator access to CloudTrail and the manifest bucket's S3 server access logs. Reconstruct the external session, then follow each service transition until the trail ends.

## 18 Flags

1. What is the source IP on the last ReceiveMessage before a non-internal IP performs ReceiveMessage on that same queue?
2. From which external IP did the contractor perform the full scout diversion attack (including PurgeQueue)?
3. On the live diversion source IP, which secret name returned AccessDenied on the first denied GetSecretValue call?
4. Which secret name was successfully read before the role assumption?
5. Which IAM role name did the attacker fail to assume before the successful pivot? (role name only, not ARN)
6. Which IAM role ARN was successfully assumed to control watchpost routing?
7. What roleSessionName was used on the successful AssumeRole?
8. What IAM identity type does CloudTrail record for API calls made after the successful role pivot?
9. What is the SQS queue name targeted for the fraudulent scout recall order?
10. What order_id value was injected in the fraudulent scout recall order?
11. What route_override destination did the attacker set in the fraudulent order?
12. What KMS keyId did the attacker use when decrypting the routing envelope after SendMessage?
13. What SNS topic name received the diversion alert Publish call?
14. What DynamoDB table name received the forged ledger PutItem?
15. What is the S3 access log operation field for the GetObject on signed-routing-bundle.json from the external IP?
16. What is the name of the CloudTrail trail the attacker verified before purging queue evidence?
17. Which API action destroyed the queue evidence at the end of the attack chain?
18. Which IAM user name owned the long-lived access key used to start the attack chain?

## Solution

```bash
aws cloudtrail lookup-events > lookup_events.json
```

Use grep and JQ after pulling the CloudTrail logs to find all the CloudTrail information.

From the CloudTrail logs we find that the s3 bucket logs are in `s3://eastreach-manifest-access-logs` and we can do an `ls` on the bucket to start enumerating it

```bash
aws s3 ls s3://eastreach-manifest-access-logs/                              

PRE eastreach-watchpost-manifests/

┌──(ghost㉿gcttoolkit66)-[/mnt/…/htb/ctf/apocalypse/empty_chairs]
└─$ aws s3 ls s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/

2026-07-27 14:44:12      97246 2026-07-13-13-44-12-56a3665e6849
2026-07-27 14:44:13      97507 2026-07-14-07-44-12-2e511c8cf44d
2026-07-27 14:44:13      97390 2026-07-15-01-44-12-98ea5c44f029
2026-07-27 14:44:13      96843 2026-07-15-19-44-12-fc3eb34ef264
2026-07-27 14:44:13      97023 2026-07-16-13-44-12-6fef14de95c3
2026-07-27 14:44:13      97491 2026-07-17-07-44-12-c478122b1a12
2026-07-27 14:44:13      97969 2026-07-18-01-44-12-28c77100ee22
2026-07-27 14:44:13      96901 2026-07-18-19-44-12-dc7100dc2ab1
2026-07-27 14:44:13      97092 2026-07-19-13-44-12-311772a366c7
2026-07-27 14:44:13      97767 2026-07-20-07-44-12-2a2b9eed3611
2026-07-27 14:44:13      97275 2026-07-21-01-44-12-d98d802c7662
2026-07-27 14:44:13      97403 2026-07-21-19-44-12-d889275daf8e
2026-07-27 14:44:13      97439 2026-07-22-13-44-12-0ecc9a731ad3
2026-07-27 14:44:13      97682 2026-07-23-07-44-12-a1ea6a32b4e8
2026-07-27 14:44:13      97217 2026-07-24-01-44-12-9bf6bd2679bb
2026-07-27 14:44:13      97393 2026-07-24-19-44-12-10ec61dea533
2026-07-27 14:44:13      97261 2026-07-25-13-44-12-852ead3ccbfc
2026-07-27 14:44:13      91777 2026-07-26-07-44-12-78a71260bc16
2026-07-27 14:44:31        598 2026-07-27-19-44-31-49a90264941147e9
2026-07-27 14:44:31        620 2026-07-27-19-44-31-cce85964a69247a3
```

```bash
aws s3 cp --recursive s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/ ./                                    

download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-17-07-44-12-c478122b1a12 to ./2026-07-17-07-44-12-c478122b1a12
download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-20-07-44-12-2a2b9eed3611 to ./2026-07-20-07-44-12-2a2b9eed3611
download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-13-13-44-12-56a3665e6849 to ./2026-07-13-13-44-12-56a3665e6849
download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-15-01-44-12-98ea5c44f029 to ./2026-07-15-01-44-12-98ea5c44f029
download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-14-07-44-12-2e511c8cf44d to ./2026-07-14-07-44-12-2e511c8cf44d
download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-16-13-44-12-6fef14de95c3 to ./2026-07-16-13-44-12-6fef14de95c3
download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-15-19-44-12-fc3eb34ef264 to ./2026-07-15-19-44-12-fc3eb34ef264
download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-18-01-44-12-28c77100ee22 to ./2026-07-18-01-44-12-28c77100ee22
download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-18-19-44-12-dc7100dc2ab1 to ./2026-07-18-19-44-12-dc7100dc2ab1
download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-19-13-44-12-311772a366c7 to ./2026-07-19-13-44-12-311772a366c7
download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-22-13-44-12-0ecc9a731ad3 to ./2026-07-22-13-44-12-0ecc9a731ad3
download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-23-07-44-12-a1ea6a32b4e8 to ./2026-07-23-07-44-12-a1ea6a32b4e8
download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-27-19-44-31-49a90264941147e9 to ./2026-07-27-19-44-31-49a90264941147e9
download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-21-19-44-12-d889275daf8e to ./2026-07-21-19-44-12-d889275daf8e
download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-24-01-44-12-9bf6bd2679bb to ./2026-07-24-01-44-12-9bf6bd2679bb
download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-25-13-44-12-852ead3ccbfc to ./2026-07-25-13-44-12-852ead3ccbfc
download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-26-07-44-12-78a71260bc16 to ./2026-07-26-07-44-12-78a71260bc16
download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-24-19-44-12-10ec61dea533 to ./2026-07-24-19-44-12-10ec61dea533
download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-27-19-44-31-cce85964a69247a3 to ./2026-07-27-19-44-31-cce85964a69247a3
download: s3://eastreach-manifest-access-logs/eastreach-watchpost-manifests/2026-07-21-01-44-12-d98d802c7662 to ./2026-07-21-01-44-12-d98d802c7662
```

Looking through the log files, grep and manually, we can find the answer we are looking for in `2026-07-27-19-44-31-cce85964a69247a3`

```bash
# Q1 — last internal ReceiveMessage IP before external ReceiveMessage on same queue
jq -r '.Events[].CloudTrailEvent | fromjson | select(.eventName=="ReceiveMessage") | select(.requestParameters.queueUrl=="https://sqs.us-east-1.amazonaws.com/719384620571/eastreach-scout-recall-pending") | "\(.eventTime) \(.sourceIPAddress) \(.userIdentity.arn)"' lookup_events.json | sort

# Q2 — external IP that ran the full diversion attack (PurgeQueue is the unique marker)
jq -r '.Events[].CloudTrailEvent | fromjson | select(.eventName=="PurgeQueue") | .sourceIPAddress' lookup_events.json

# Q3 — first denied GetSecretValue secret name on the live diversion IP
jq -r '.Events[].CloudTrailEvent | fromjson | select(.eventName=="GetSecretValue" and .sourceIPAddress=="203.0.113.88" and .errorCode=="AccessDeniedException") | "\(.eventTime) \(.requestParameters.secretId)"' lookup_events.json | sort | head -1

# Q4 — secret successfully read before role assumption
jq -r '.Events[].CloudTrailEvent | fromjson | select(.eventName=="GetSecretValue" and .sourceIPAddress=="203.0.113.88" and (.errorCode==null)) | .requestParameters.secretId' lookup_events.json

# Q5 — failed AssumeRole target role name (not ARN)
jq -r '.Events[].CloudTrailEvent | fromjson | select(.eventName=="AssumeRole" and .sourceIPAddress=="203.0.113.88" and .errorCode=="AccessDenied") | .requestParameters.roleArn | split("/") | last' lookup_events.json

# Q6 — successfully assumed role ARN
jq -r '.Events[].CloudTrailEvent | fromjson | select(.eventName=="AssumeRole" and .sourceIPAddress=="203.0.113.88" and (.errorCode==null)) | .requestParameters.roleArn' lookup_events.json

# Q7 — roleSessionName on the successful AssumeRole
jq -r '.Events[].CloudTrailEvent | fromjson | select(.eventName=="AssumeRole" and .sourceIPAddress=="203.0.113.88" and (.errorCode==null)) | .requestParameters.roleSessionName' lookup_events.json

# Q8 — IAM identity type recorded after the pivot
jq -r '.Events[].CloudTrailEvent | fromjson | select(.sourceIPAddress=="203.0.113.88" and .userIdentity.type=="AssumedRole") | .userIdentity.type' lookup_events.json | sort -u

# Q9 — SQS queue name for the fraudulent recall order
jq -r '.Events[].CloudTrailEvent | fromjson | select(.eventName=="SendMessage" and .sourceIPAddress=="203.0.113.88") | .requestParameters.queueUrl | split("/") | last' lookup_events.json

# Q10 & Q11 — order_id and route_override from the injected message body
jq -r '.Events[].CloudTrailEvent | fromjson | select(.eventName=="SendMessage" and .sourceIPAddress=="203.0.113.88") | .requestParameters.messageBody' lookup_events.json

# Q12 — KMS keyId used in Decrypt
jq -r '.Events[].CloudTrailEvent | fromjson | select(.eventName=="Decrypt" and .sourceIPAddress=="203.0.113.88") | .requestParameters.keyId' lookup_events.json

# Q13 — SNS topic name for the diversion alert
jq -r '.Events[].CloudTrailEvent | fromjson | select(.eventName=="Publish" and .sourceIPAddress=="203.0.113.88") | .requestParameters.topicArn | split(":") | last' lookup_events.json

# Q14 — DynamoDB table name for the forged ledger entry
jq -r '.Events[].CloudTrailEvent | fromjson | select(.eventName=="PutItem" and .sourceIPAddress=="203.0.113.88") | .requestParameters.tableName' lookup_events.json

# Q15 — S3 access log Operation field for the GetObject on signed-routing-bundle.json
grep "signed-routing-bundle.json" 2026-07-27-19-44-31-* | grep "203.0.113.88" | grep -oE 'REST\.[A-Z._]+'

# Q16 — CloudTrail trail name verified before the purge
jq -r '.Events[].CloudTrailEvent | fromjson | select(.eventName=="GetTrailStatus" and .sourceIPAddress=="203.0.113.88") | .requestParameters.name' lookup_events.json

# Q17 — API action that destroyed the queue evidence
jq -r '.Events[].CloudTrailEvent | fromjson | select(.eventName=="PurgeQueue") | .eventName' lookup_events.json

# Q18 — IAM user owning the long-lived access key that started the attack chain
jq -r '[.Events[].CloudTrailEvent | fromjson] | sort_by(.eventTime) | .[0] | "\(.eventTime) \(.userIdentity.arn) \(.userIdentity.accessKeyId)"' lookup_events.json
```

| #   | Question                                                                    | Answer                                                                         |
| --- | --------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| 1   | Last internal `ReceiveMessage` IP before external on same queue             | **`10.23.87.41`**                                                              |
| 2   | External IP for full diversion (incl. PurgeQueue)                           | **`203.0.113.88`**                                                             |
| 3   | First denied `GetSecretValue` secret name (on live IP)                      | **`eastreach/dispatch-signing-draft`**                                         |
| 4   | Secret successfully read before role assumption                             | **`eastreach/dispatch-signing`**                                               |
| 5   | Failed AssumeRole target role (name only)                                   | **`eastreach-archive-reader`**                                                 |
| 6   | Successfully assumed role ARN                                               | **`arn:aws:iam::719384620571:role/eastreach-dispatch-role`**                   |
| 7   | roleSessionName used                                                        | **`dispatch-runner`**                                                          |
| 8   | IAM identity type after pivot                                               | **`AssumedRole`**                                                              |
| 9   | SQS queue for fraudulent recall order                                       | **`eastreach-scout-recall-pending`**                                           |
| 10  | Injected `order_id`                                                         | **`ER-DIV-9941`**                                                              |
| 11  | `route_override` destination                                                | **`quietmarch-depot-11/bypass-C`**                                             |
| 12  | KMS keyId used in Decrypt                                                   | **`arn:aws:kms:us-east-1:719384620571:alias/eastreach/watchpost-routing-key`** |
| 13  | SNS topic for diversion alert                                               | **`eastreach-diversion-alerts`**                                               |
| 14  | DynamoDB table for forged ledger PutItem                                    | **`eastreach-watchpost-ledger`**                                               |
| 15  | S3 access log operation field for GetObject on `signed-routing-bundle.json` | **`REST.GET.OBJECT`**                                                          |
| 16  | CloudTrail trail verified before purge                                      | **`eastreach-watchpost-trail`**                                                |
| 17  | API action that destroyed queue evidence                                    | **`PurgeQueue`**                                                               |
| 18  | IAM user owning long-lived key that started the chain                       | **`eastreach-contractor`**                                                     |

### Files

<!-- Any provided files to work with -->
## Lessons Learned

<!-- Anything worth remembering for next time - technique, gotcha, tool quirk -->
