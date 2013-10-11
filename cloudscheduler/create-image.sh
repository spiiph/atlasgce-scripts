#!/usr/bin/env sh

error()
{
  echo "ERROR: $1" >& 2
}

usage()
{
  echo "Usage: $(basename $0) image-name"
}

if [ $# -le 0 ]
then
  error "Too few arguments"
  usage
  exit 2
fi

gsutil ls gs:// >/dev/null 2>&1
if [ $? -ne 0 ]
then
  error "Failed to access Google Storage; have you run gsutil config?"
  exit 3
fi

echo "Creating image..."
sudo python /usr/share/imagebundle/image_bundle.py \
  --root=/ \
  --output_directory=/tmp \
  --output_file_name=$1.image.tar.gz \
  --excludes=$HOME/cloudscheduler \
  --log_file=/tmp/image.log

# NOTE: Remember to run gsutil config before
echo "Creating bucket $1..."
gsutil mb gs://$1

echo "Copying image to bucket $1..."
gsutil cp /tmp/$1.image.tar.gz gs://cloudscheduler-centos

# gcutil --project=<project-id> addimage <image-name> <image-uri>
# --preferred_kernel=projects/google/global/kernels/<kernel-name>
