---
tags:
  - ctf
  - aws
  - CloudTrail
difficulty: medium
category: cloud
---
# Challenge

Caldrin Vowmark reaches an Ashguard checkpoint with a sealed order that tells Stormbound's soldiers to leave the east gate and report to Crownspire. The officer in charge believes the order came from Garran Voss, and he will move his soldiers as soon as the seal is checked. If they leave, Vaultrune can take the gate before help arrives. Caldrin knows Garran's orders carry small marks that copyists miss. He has to inspect the order, show the officer that it is false, and stop the unit from leaving before Vaultrune's soldiers reach the gate.

To prove whether the order was replaced and identify who changed it, you have read-only investigator access to CloudTrail trail `coalition-gate-audit-trail` and the versioned bucket `ashguard-order-custody`. Begin with `custody/east-gate-order.json`, then correlate its version history with the audit events.

## 12 Flags

1. What was the last CloudTrail API action performed from the internal gatehouse IP immediately before the attacker session began?
2. What was the first CloudTrail API action called from the attacker IP?
3. Which S3 API action did the attacker attempt that was explicitly denied before assuming a role?
4. What is the full S3 path of the object that was tampered with? (format s3://bucket/key)
5. Which IAM role was assumed for the destructive session? (ARN format)
6. What was the full STS principal ARN on the DeleteObject call?
7. From which IP address were the AssumeRole and destructive S3 calls performed?
8. Which IAM username owns the long-lived credentials used to call AssumeRole?
9. Which IAM role name did the attacker fail to assume before the successful AssumeRole? (role name only, not ARN)
10. What roleSessionName was used on the successful AssumeRole into the scanner role?
11. What errorCode did CloudTrail record on the denied GetObject probe before role assumption?
12. Which S3 API action name marks the forged ledger upload after DeleteObject?
## Solution

```bash
aws cloudtrail lookup-events > lookup_events.json
```

Use grep and JQ after pulling the CloudTrail logs to find all the information.

- **Last internal gatehouse action before attacker session:** `ListObjectsV2` — 2026-07-27T16:29:27.909Z from `10.41.53.22`
- **First action from attacker IP:** `GetCallerIdentity` — 2026-07-27T16:30:27.532Z from `198.18.44.91`
- **S3 action denied before role assumption:** `GetObject` (AccessDenied at 17:10:29.677Z)
- **Tampered object path:** `s3://ashguard-order-custody/custody/east-gate-order.json`
- **Role assumed for destructive session:** `arn:aws:iam::638291047582:role/ashguard-order-scanner`
- **STS principal ARN on DeleteObject:** `arn:aws:sts::638291047582:assumed-role/ashguard-order-scanner/coalition-gate-clerk`
- **IP for AssumeRole + destructive S3 calls:** `198.18.44.91`
- **IAM username owning long-lived creds that called AssumeRole:** `seal-copyist-contractor`
- **Role name failed on first AssumeRole attempt:** `ashguard-order-auditor`
- **roleSessionName on successful AssumeRole into scanner role:** `coalition-gate-clerk` (note: the attacker impersonated the legitimate clerk's session name — that's the "small mark" giveaway, since the _access key/user identity_ is `seal-copyist-contractor` but they set the session name to `coalition-gate-clerk` to blend in)
- **errorCode on denied GetObject probe:** `AccessDenied`
- **S3 action marking the forged upload after DeleteObject:** `PutObject`

## Lessons Learned

<!-- Anything worth remembering for next time - technique, gotcha, tool quirk -->
