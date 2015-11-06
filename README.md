# OpenMediaVault Docker Container

Basic Docker container for OpenMediaVault primarily useful
in plugin development.

- Expose ports 80 and 443 by default
- Data directory should be in /data and will contain
  /etc/openmediavault and /etc/default
- First run will copy installed config files into the
  data directory

```
docker run --name OpenMediaVault -ti -h openmediavault.example.test -v /path/to/data:/data:Z ikogan/openmediavault
```

Note, this is a work in progress and may not be functioning
at the moment.
