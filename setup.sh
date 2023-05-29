#!/bin/bash
gcloud compute instances list --filter="status=terminated" --format="value(name,zone,creation_timestamp)" |
while read name zone creation_timestamp
do
  echo "Instance name: $name"
  echo "Created on $creation_timestamp"
  gcloud compute instances delete $name --zone=$zone --quiet
done