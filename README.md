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

## Alternative Branches

- extras: Includes omv-extras pre-installed
