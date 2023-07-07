#!/bin/bash

gcloud_list_instances () {
# use:  gcloud_list_instances (status, zone)
echo "Pierwsza $1"
echo "Druga $2"

gcloud compute instances list --filter="status=$1" --format="value(name,$2,creation_timestamp)" |
gcloud compute instances list --filter="status=terminated" --format="value(name,zone,creation_timestamp)" |
while read name zone creation_timestamp
do
  echo "Instance name: $name"
  echo "Created on $creation_timestamp"
  ##################### gcloud compute instances delete $name --zone=$zone --quiet
done
}

gcloud_list_instances ("terminated", us-west1)