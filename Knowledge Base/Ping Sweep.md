Using a ping sweep can be useful to find hosts on a network from a pivot machine that you cannot use nmap or fping on. It will allow you to use the basic ping command to send out a bunch of ICMP requests and look to see who replied to them. This won't work on hosts that have ICMP turned off, filtered, or blocked, but is a good starting point for recon on a new network.

You can run a ping sweep in multiple different ways and it will depend on the access that you have on that machine as well as the OS of that host

### MetaSploit

#MetaSploit #meterpreter 
You can do it through a metasploit/meterpreter session using the module "post/multi/gather/ping_sweep" this will allow you to run it through the metasploit command interface with a session that you already have running by setting the network and the session or through the session itself with the following line and all you will need to do is change out the rhosts to the subnet that you want to scan. 

```meterpreter
run post/multi/gather/ping_sweep rhosts=172.16.16.1/23
```

### Terminal

If you do not have access to a meterpreter session, you can run a ping sweep with Bash, Windows CMD, or Windows PowerShell as long as you have access to the ping command.

```bash
for i in {1..254} ;do (ping -c 1 172.16.5.$i | grep "bytes from" &) ;done
```

```CMD
for /L %i in (1 1 254) do ping 172.16.5.%i -n 1 -w 100 | find "Reply"
```

```PowerShell
1..254 | % {"172.16.5.$($_): $(Test-Connection -count 1 -comp 172.15.5.$($_) -quiet)"}
```
