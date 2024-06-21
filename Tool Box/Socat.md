Socat is a two direction relay tool that allows you to create pipe sockets between two networks without needing to use SSH. It acts as a redirect that listens on one host and then port forwards that data to a different IP address and port.

*Starting a Socat Listener*
```bash
socat TCP4-LISTEN:8080,fork TCP4:10.10.14.18:80
```

This command is being run on the pivot host that we have gotten access to
TCP4-Listen is the port that Socat will listen on 
TCP4 is our attack machine IP address and port 80 is where the traffic will be sent to

