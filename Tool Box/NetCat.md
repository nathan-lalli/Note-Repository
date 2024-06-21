## #NetCat #NC 

NetCat can be used to connect to a host or target system and get information back from that system

This can be used to get information data and any other metadata that may be stored in the header/banner of that port/service

*Connect to an IP address on the given port and be verbose*
```bash
nc -nvv <target> <port>
```

*Connect to an IP address on the given port from a specific port and be verbose*
```bash
nc -nvv -p <source-port> <target> <port>
```
