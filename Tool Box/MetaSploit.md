#MetaSploit 

*Running this from a session in the meterpreter will add a route from that machine to the subnet that is specified*
```msfconsole
run autorecon -s <subnet>
```

*Running this from a session in the meterpreter will create a port forward to the victim ip address and port to your attack machine on the given port*
```msfconsole
portfwd add -l <local port to bind to> -p <victim port> -r <victim ip>
```

*Gives the network interface information for the victim*
```msfconsole
ipconfig
```
