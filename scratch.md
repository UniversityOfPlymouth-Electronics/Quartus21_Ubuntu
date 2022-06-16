
In the platforms folder, I ran the following to find a dependency on libudev.so.0


```bash
for FILE in *; do echo $FILE; ldd $FILE | grep -i libudev; done
```

The results is as follows:

```bash
libqlinuxfb.so
	libudev.so.0 => /lib/x86_64-linux-gnu/libudev.so.0 (0x00007f87d84b5000)
libqminimal.so
libqoffscreen.so
libqvnc.so
	libudev.so.0 => /lib/x86_64-linux-gnu/libudev.so.0 (0x00007fa52d59b000)
libqxcb.so
```

So it looks like the following libraries are the issue:
```
libqlinuxfb.so
libqvnc.so
```

Some other packages on my system uses these libraries:

```bash
dpkg -S libqlinuxfb.so
```

# Oldlibs (Ubuntu)

Seems I have found it

https://packages.ubuntu.com/impish/amd64/libudev0/download

