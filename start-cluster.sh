#!/usr/bin/env sh

gcutil addinstance head \
  --cache_flag_values \
  --image projects/centos-cloud/global/images/centos-6-v20130522 \
  --machine_type n1-standard-1-d \
  --zone europe-west1-b \
  --metadata_from_file=node-template:gce_head_node.pp \
  --metadata_from_file=mount-script:mount-head.sh \
  --metadata_from_file=startup-script:bootstrap.sh

gcutil addinstance node01 node02 \
  --cache_flag_values \
  --image projects/centos-cloud/global/images/centos-6-v20130522 \
  --machine_type n1-standard-1-d \
  --zone europe-west1-b \
  --metadata_from_file=node-template:gce_worker_node.pp \
  --metadata_from_file=mount-script:mount-worker.sh \
  --metadata_from_file=startup-script:bootstrap.sh
