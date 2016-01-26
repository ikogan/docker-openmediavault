# OpenMediaVault Docker Container

Basic Docker container for OpenMediaVault primarily useful
in plugin development.

- Expose ports 80 and 443 by default
- Data directory should be in /data and will contain
  /etc/openmediavault, /etc/default, /var/log, and /var/lib
- First run will copy installed config files into the
  data directory and symlink them into the system

```
docker run --name OpenMediaVault -d -ti -h openmediavault.example.test -v /path/to/data:/data:Z -P ikogan/openmediavault
```

## Configuration
A configuration file can be placed at the root of the data
directory called `container.ini` that will be used to configure
various services on startup. Currently, the configuration supports
the following options:

```
[nginx]
httpPort="80";
httpsPort="443";

[data]
alwaysClear="false";
```

## Alternative Branches

- extras: Includes omv-extras pre-installed
- dev: Includes extras and development plugin

## Block Devices

In order to use much of OpenMediaVault, you will need some kind of block
or possibly a remote NFS mount. For the former, using the `--device`
option to `docker run` can give the container access to a physical device.
*Make sure it's mounted on only one container and never on a container
and the host*. You can use a loop device if you don't have any physical devices.
Sometimes these can be a bit flaky, so in some cases, using Fake Shared Folders
might work better, see the later section for more information.

First, use `--cap-add=SYS_ADMIN --device=/dev/loop0:/dev/loop0`
when running the container, then run `losetup /dev/loop0 /data/shared.img` when
in the container (assuming your image is `/data/shared.img`).
There are a couple of important caveats:

- Adding the `SYS_ADMIN` capability to your container will allow it to modify
  aspects of your system, you've been warned, you should Google it.
- The loop device will persist outside of the container as it's actually setup
  on the host. Your startup script should use `losetup -d /dev/loop0` to
  destroy it.
- This is apparently flakey on Mac OS X. If OpenMediavault fails to properly
  create filesystems or mount the container from the GUI, you'll need to do
  some of those steps manually. Simply create the filesystem first with
  something like `mkfs.ext4 -F /data/shared.img` (assming /data/shared.img is
  your filesystem, *never use -F on a live filesystem*) first. Then, try and
  mount it in the GUI. Apply the configuration even if that fails. You should
  get another error, but a directory in `/media` will be created. Mount the
  device with `mount /dev/loop0 /media/omv-generated-uuid-directory`, then
  try and save the configuration again. It should now succeed.

## Fake Shared Folders

It may be easier to simply manually configure OpenMediaVault to have a shared
folder that's simply a directory on the filesystem, and isn't bound to a block
device. You'll need to use the OMV command line tools to set this up:

```sh
/bin/bash
set -e

FSPATH="${1}"
FSNAME="${2}"

if [[ -z "${FSPATH}" || -z "${FSNAME}" ]]; then
    echo "Usage: ${0} <fspath> <fsname>
    exit 1
fi

mkdir -p "${FSPATH"} || true

MNT_ENT_XPATH="/config/system/fstab/mntent"
SHARE_XPATH="/config/system/shares/sharedfolder"

# In this case, we always only want one shared folder, so
# we're going to nuke any others because we're assuming they're
# not what they want.
if [[ "$(omv_config_get_count ${MNT_ENT_XPATH})" -gt 0 ]]; then
    omv_config_delete ${MNT_ENT_XPATH}/*
else
    omv_config_add_element "/config/system/fstab" "mntent"
fi

if [[ "$(omv_config_get_count ${SHARE_XPATH})" -gt 0 ]]; then
    omv_config_delete ${SHARE_XPATH}/*
else
    omv_config_add_element "/config/system/shares" "sharedfolder"
fi

# OMV wants each mount and shared folder to have a universally
# unique identifier, generate some
MNT_ENT_UUID=$(uuid)
SHARE_UUID=$(uuid)

# Create the mount entry for this share
omv_config_add_element ${MNT_ENT_XPATH} uuid ${MNT_ENT_UUID}
omv_config_add_element ${MNT_ENT_XPATH} fsname "${FSNAME}"
omv_config_add_element ${MNT_ENT_XPATH} dir "${FSPATH}"
omv_config_add_element ${MNT_ENT_XPATH} type none
omv_config_add_element ${MNT_ENT_XPATH} opts "rw,relatime,xattr"
omv_config_add_element ${MNT_ENT_XPATH} freq 0
omv_config_add_element ${MNT_ENT_XPATH} passno 0
omv_config_add_element ${MNT_ENT_XPATH} hidden 0

# Create the shared folder
omv_config_add_element ${SHARE_XPATH} uuid ${SHARE_UUID}
omv_config_add_element ${SHARE_XPATH} name "${FSNAME}"
omv_config_add_element ${SHARE_XPATH} comment ""
omv_config_add_element ${SHARE_XPATH} mntentref ${MNT_ENT_UUID}
omv_config_add_element ${SHARE_XPATH} reldirpath "/"
```
