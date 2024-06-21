## #Writing_Data 

On Linux, the "/tmp" folder is almost always writable to anyone

On Windows, the "%TEMP%" folder is almost always writable to anyone

## #ssh 

You can generate an ssh key using sshkeygen and the public key and private key are saved to the "~/.ssh" folder by default

Placing your public key into the "~/.ssh/authorized_users" folder allows you to ssh in as that user with your private key

## #chmod

chmod 600 {filename} is what you will use to make an ssh key

chmod +x is what you will use to make a script executable

## #Pipe

You can pipe the output of a curl, or anything else, to "sh" to get that to run in the shell. This is useful if you don't have permission to create a file but you can curl something still

## #Chroot

Chroot into a system that is mounted onto a different machine in order to run as root as if you were on that machine

You have to mount the partition into a directory on your device and then you can chroot into and run as if you were on that machine.

When mounting it is helpful to copy over the network file as well so that you can resolve domain names if you need to get out to the Internet. The below command will do that for you

```bash
cp -L /etc/resolv.conf /mnt/etc/resolv.conf
```

## #Linux 

executable files go into /usr/bin, resources into /usr/share, config files into /etc, and logs into /var/logs

