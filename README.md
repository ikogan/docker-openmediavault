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
