This is what you can do to get a better stabilized shell that you can use arrow keys and other special options and key binds with

Step 1:
```python
python3 -c 'import pty;pty.spawn("/bin/bash")'
```

Step 2:
 Do a ctrl-Z in the terminal to make the current process a background job 

Step 3:
```bash
stty raw -echo; fg
```

Step 4:
```bash
export TERM=xterm
```
