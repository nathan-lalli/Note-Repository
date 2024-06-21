Sshuttle is a proxy tool that will allow us to proxy anything over ssh without having to use proxychains. The only downside is that it only does SSH and cannot do TOR or HTTPS proxying

*Setting up the Sshuttle Proxy*
```bash
sudo sshuttle -r ubuntu@10.129.202.64 172.16.5.0/23 -v
```

The -r flag tells shuttle to connect to the remote machine with a username and password
The address after the -r is the username and IP address for out pivot host
The next address is the network that we want to route our pivot to

Once this is run, we can now use ANY tools on our machine has if we were on that network because this creates an entry into out iptables to redirect all traffic to that network