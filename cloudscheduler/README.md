# Cloud Scheduler

These scripts are used to contextualize a Cloud Scheduler worker node as well as to prepare a GCE machine image for contextualization by Cloud Scheduler.

# Contextualization

When a machine is started as a Cloud Scheduler worker node it must be provided with [Nimbus](http://www.nimbusproject.org/) context data in the `user-data` attribute. The format of the context data is XML format and it is exemplified in [here](https://github.com/spiiph/atlasgce-modules/cloudscheduler/contexthelper#L8-L19).

This context data should contain the contents of `bootstrap.sh` which will be retrieved, stored, and executed by the `contexthelper` at boot. The bootstrapping procedure is different from the manager and worker roles in that the mount script and the node template are embedded in `bootstrap.sh`, but the steps are conceptually the same.

# Creating the custom machine image

In order to start Cloud Scheduler worker nodes a custom machine image must be prepared with the `context` and `contexthelper` scripts. To create such an image follow this procedure

1. Upload the contents of the `cloudscheduler` directory to `$HOME` on the machine.
```
gcutil push <host> cloudscheduler .
```

2. Run `setup.sh` to install `/etc/init.d/context` and `/usr/local/bin/contexthelper` and configure `context` to run on boot.

3. Run `create-image.sh` to run GCE's image creation software and upload the newly baked image to Google Storage. If a bucket is not provided `cloudscheduler` is used.

```
./create-image.sh <image-name> [bucket]
```

4. Add the image to the GCE project (where `<image-uri>` is of the form `gs://<bucket>/<image-name>`).

```
gcutil --project=<project-id> addimage <image-name> <image-uri> --preferred_kernel=projects/google/global/kernels/<kernel-name>
```
