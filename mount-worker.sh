#!/usr/bin/env sh

format_and_mount()
{
  echo "Creating logical volume $1 with $3 and mount point $2..."
  lvcreate $3 --name $1 vg00
  mkdir -p $2
  /usr/share/google/safe_format_and_mount -m "mkfs.ext4 -F -m 2" /dev/vg00/$1 $2
}

DISK_PATH=/dev/disk/by-id/google-ephemeral-disk-
for disk in $DISK_PATH*
do
  echo "Creating physical volumes (pvcreate)..."
  pvcreate $disk
done

echo "Creating volume group (vgcreate)..."
vgcreate vg00 $DISK_PATH*

format_and_mount lv_cvmfs /var/cache/cvmfs2 "--size 30G"
format_and_mount lv_condor /var/lib/condor "--size 120G"
format_and_mount lv_xrootd /data/scratch "--extents 100%FREE"
