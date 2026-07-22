---
tags:
  - knowledge-base
  - nmcli
  - ip
category: linux
---
# Overview

Adding a static route to your machine allows you to bypass the default gateway routing and tell your machine where to go directly. This can help if there are network rules in place or if you need to access a network that is on the other side of a different machine like a firewall or proxy.

## Temporary Route

You can use the ip tool to add a static route, but this will not persist on reboot

```bash
sudo ip route add 10.0.0.0/24 via 192.168.1.2
```

This creates a route to the 10.0.0.0/24 subnet through the host 192.168.1.2

## nmcli

To create a permanent route, we can use nmcli.
We can also specify the network that the route is for so that we can connect to a different network and the route will not follow us there. This is helpful so that we don't accidentally break routing when we don't need to.

Show the current connections we have

```bash
sudo nmcli conn show
```

Grab the name of the network that we want to add the route to from the output above

Add the route to the network from above

```bash
sudo nmcli conn modify "Network Name" +ipv4.routes "10.0.0.0/24 192.168.1.2"
```

Now we need to restart the connection to apply this change

```bash
sudo nmcli conn up "Network Name"
```

We now have a route to the 10.0.0.0/24 subnet through the host 192.168.1.2 on the network with the name "Network Name"