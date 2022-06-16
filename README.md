# Quartus 21 for Ubuntu 20.04
Setup instructions for Intel® Quartus® 21.x and Questa® for Ubuntu 20.04. These notes are intended for internal use at the University of Plymouth UK. This repository has been made public in case they should benefit others.

We have only tested this with a Terasic DE0-Nano FPGA board.

## Disclaimer
The notes below are collated from various sources in the Internet. 

* There is **NO GUARANTEE** these notes or scripts will work
* These notes are a best effort to install Quartus 21.1 on Ubuntu 20.04. They are subject to change in the light of new information.
* **Use at your own risk**. Neither the author or the University of Plymouth accept any liability for content of this repository. 

## Download and install Ubuntu 20.04 LTS
You will need an installation of Ubuntu Desktop 20.04 LTS. This can be obtained from https://ubuntu.com/download/desktop

Your will need to sign in a user with sudo rights (the default)

I have performed tests with both a Physical machine and a virtual machine (with USB pass-through).

## Download Quartus
The version we are using is Intel Quartus Prime Lite Edition, v21.1
https://www.intel.com/content/www/us/en/software/programmable/quartus-prime/download.html

You will probably need to create an account on the Intel site.

At the time of writing, a [direct link can be found here](https://www.intel.com/content/www/us/en/software-kit/684215/intel-quartus-prime-lite-edition-design-software-version-21-1-for-linux.html)

We download the following:

* Intel® Quartus® Prime (includes Nios® II EDS)
* Questa*-Intel® FPGA Edition
* Intel® Cyclone® IV Device Support

## Obtain a free License for Questa*-Intel® FPGA Starter Edition
For Questa, you will also need a license for your machine (linked to the hardware address of your network interface)

Visit the [Intel® FPGA Self-Service Licensing Center](https://www.intel.com/content/www/us/en/docs/programmable/683472/21-4/fpga-self-service-licensing-center.html) and create a single free license for Questa*-Intel® FPGA Starter Edition 

This results in a license file (extension .DAT) being emailed to your registered email address. You need to save this file on your machine.

## Install Quartus and Questa
Download all the installers for Quartus and Questa. You only need to run the Quartus Lite installer (this will install Questa for you)

All the files should be in the same folder. I am going to install locally (for just one user). We will discuss installing globally later.

Open a terminal and change to the directory with all the installers and type:


```bash
chmod +x QuartusLiteSetup-21.1.0.842-linux.run
```

This makes the installer e**x**ecutable. Follow the instructions on screen.

By the end of this process, you should have an icon on the desktop. You might need to right-click this to allow it to be executable.

## udev rules
Quartus should now be able to run, but my default, it will not have sufficient rights to communicate with the DE0-Nano board.

The DE0-Nano board (like many) has a USB Blaster J-Tag programmer built in. This USB device will only be accessible by the root user. Quartus on the other hand will be running with normal user permissions. This is where `udev` comes in.

As a sudo user, create a file as folows:

```bash
sudo nano /etc/udev/rules.d/51-usbblaster.rules 
```

Paste in the following:

```bash
# USB-Blaster
SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6001", MODE="0666"
SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6002", MODE="0666"
SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6003", MODE="0666"
# USB-Blaster II
SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6010", MODE="0666"
SUBSYSTEM=="usb", ATTRS{idVendor}=="09fb", ATTRS{idProduct}=="6810", MODE="0666"
```

Alternatively, a copy of this file is included in this repository, in which case you would write:

```bash
sudo cp 51-usbblaster.rules /etc/udev/rules.d
```

Once the above is done, type the following:

```bash
sudo udevadm control --reload
```

At this point, I do a **reboot**. I am not sure if this is needed, but I do it anyway!

Now, when you plug in your USB-Blaster device, the permissions should be updated. 

### Confirming the udev rules (optional)

We can verify that udev has given us the correct permission by looking at the file system (all devices appear as files in Linux)

First, with the board plugged in, we can type the following:

```bash
lsusb | grep -i blaster
```

From this you can find the BUS and Device number. In my case, I get the following output:

```
Bus 001 Device 019: ID 09fb:6001 Altera Blaster
```

Knowing my device is device 019 on bus 001, I can inspect the permissions as follows:


```bash
ls -l /dev/bus/usb/001/019
```

and I see the following:

```bash
crw-rw-rw- 1 root root 189, 18 Jun 16 13:28 /dev/bus/usb/001/019
```

Note that user, group and other all have read (r) and write (w) access. Nice. Now we can proceed.


## User and License Path
Questa will not run unless you have a license for your machine.

This step assumes you've obtained a license file from Intel, and saved it in the `intelFPGA_lite` folder within your home directory.

You now need to edit the .bashrc file by typing:

```bash
nano .bashrc
```

Add the following to the end:

```bash
export QROOT="$HOME/intelFPGA_lite/21.1"
export QSYS_ROOTDIR="$QROOT/quartus/sopc_builder/bin"
export PATH=$PATH:$QROOT/questa_fse/bin:$QROOT/quartus/linux64:$QROOT/quartus/bin
export LM_LICENSE_FILE="$HOME/intelFPGA_lite/LR-084006_License.dat"
```

You may need to change `$QROOT` if you installed in another location. 

* The name of your license file will also be different to mine.

Save (CTRL-o) and exit (CTRL-x) from nano. For this to take immediate effect, you can type 

```bash
source .bashrc
```

You can also simply close your terminal and start another. The belt-and-braces option is to log out and back in again. To test, simply type the following:

```bash
vsim .
```

and questa should launch.

## Programming the FPGA - workaround

You can open the sample Quartus project included in this repository. What you are likely to discover is that the programming step does not work.

When the programmer runs, it seems to look for the shared library `libudev.so.0`

If it is not present, then the programmer seems to block until it times out with the error message *Unable to read device chain - JTAG chain broken*


Version 0 of this library seems to have been removed from the Debian package repository. Instead, you will likely find `libudev.so.1`

If in doubt, install the the libudev1 package1.

```bash
sudo apt instal libudev1
```

If you are curious, type `dpkg -L libudev1` to confirm the exact version of the library and to see where it is installed.

With version 1 installed, as a workaround, the following seems to get things working:

```bash
sudo ln -sf /lib/$(arch)-linux-gnu/libudev.so.1 /lib/$(arch)-linux-gnu/libudev.so.0
```

> **Note** this really is only a **workaround**, and *there may be negative side-effects*. 
>
> Until Intel changes the dependencies of it’s programmer, I am not aware of any alternative.
>
> It might be possible to download `libudev.so.0` but at the time of writing, I do not know a secure place to do this


### Testing 

To test, plug in your board, open a terminal and type the following:

```bash
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$QROOT/quartus/linux64"

jtagconfig
```

For my board (DE0-NANO), I see the following identifiers:

```
1) USB-Blaster [1-4.4.3]
020F30DD 10CL025(Y|Z)/EP3C25/EP4CE22
```

From this point, Quartus seems to work without further changes. Note I do not need to run / kill `jtagd` or set any additional environmental variables as some sites suggest. 

From this point, when you plug in your board, it should just work.




