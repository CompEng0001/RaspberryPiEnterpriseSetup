# Customizing NOOBS
What is really surprising is that it is easy to customize NOOBS.

The key idea is that the operating systems that the user is presented with are all stored in folders in the \os directory. 
For example, the Raspbian OS is stored in:

`\os\Raspbian`

If you look into the OS directory then you will find that there are some files that are still compressed.

That is you download a zip file and then uncompress this to get the files that need to be copied onto the SD card - but some of these files are still in compressed format.

In fact the major portion of the OS is going to be in a compressed TAR file simply to save space. The only problem with this is that if you are a Windows user then both TAR files and the methods used to compress them are going to be unfamiliar and difficult to work with.

In the case of Raspbian you will find two main OS components - 

`os\Raspbian\root.tar.xz`

which is the entire file system for the OS including all of the installed packages and configuration files in their usual directories and

`os\Raspbian\boot.tar.xz`

which contains the kernel image and the main OS configuration files. 
Notice that root.tar.xz contains the entire file system that you see when you list the files in the root of the OS e.g. bin, dev, home etc.. So in principle all you have to do to create a custom NOOBS boot is to convert all of the files in the root directory to a TAR file and then compress it using xz compression. The final step is to replace the 
`root.tar.xz` file in the os\Raspbian directory on the NOOBS SD you are going to boot from and change a configuration file to indicate the size of the partition needed. 

Let's see how to do this in detail.

## A Boot To WiFi NOOBS

As an example of customizing NOOBS let's make a version of Raspbian that automatically connects to a WiFi access point with a given name SSID and password. You can connect to a WiFi access point by editing the \etc\network\interfaces to read something like:

```
auto lo
iface lo inet loopback
iface eth0 inet dhcp
auto wlan0
allow-hotplug wlan0
iface wlan0 inet dhcp
wpa-ssid "SSID"
wpa-psk "password"
iface default inet dhcp
wireless-power off 
```
Where you replace SSID and password with the correct credentials for the network. Don't worry if you don't follow this WiFi configuration the whole messy subject of making the Pi work reliably with WiFi is covered in a future chapter. 

Also note that this only works if you are using WPA authentication with the WiFi.

In practice what matters is that you have a customized interfaces file that you would like NOOBS to use when installing Raspbian.

So all we have to do now is find a way to create a TAR file and compress it using xz compression. 

If you are using Windows I the bad news is that I have failed to find an easy way of doing this. In principle 7-Zip can create both TAR files and perform xz compression, however, there seems to be something wrong with the way it creates TAR files. 

Currently there seems to be no easy reliable way of creating TAR files that NOOBS can make use of if you are working under Windows. 

At the moment the simplest thing to do is to use Linux - any yes you can use Raspbian as long as you have enough free storage on the SD card.

My preferred method is to us an Azure Ubuntu image in the cloud - as it is fast, easy, cheap and disposable after you have made a mess of it.

Taking it step-by-step is a good way to see what happens, but make sure you understand the overall strategy first:

1. unpack root.tar.xz
2. make the changes to the extracted files
3. repack the new root.tar.xz
4. reconfigure NOOBS to use your root.tar.xz
Of course; it doesn't actually matter how you get the file system that you are going to repack - you can copy it from a running machine if you want to. 

Now for the details:

## 1. Obtain and unpack root.tar.xz

First we need a copy of NOOBS in a suitable location on the machine we are going to use. 
You can copy NOOBS from anywhere you like to the machine but a simple way of getting a clean copy is to download it directly the machine:

`wget http://downloads.raspberrypi.org/NOOBS_latest`

This stores the file

`NOOBS_latest`

in the current directory.  

Next we need to unzip this file to a suitable directory. Make a directory called NOOBS:

`mkdir NOOBS`

To unzip the file we might need to install unzip

`sudo apt-get install unzip`

and then the command to unzip the NOOBS file to NOOBS is:

`unzip NOOBS_latest -d NOOBS`

Of course you might have short circuited this by copying the uncompressed files from another location directly into NOOBS. 
The unzip takes anything from ten minutes to half an hour - so go take a break!

Now we can find and expand os/Raspbian/root.tar.xz

First we need a directory to hold the files - lets call it ROOT:

`mkdir ROOT`

First we have to decompress it to a TAR file and then expand the TAR file to the directory structure. You can do this as a one step process in most up-to-date version of Linux but first make sure you have the xz utilities installed:

`sudo apt-get install xz-utils`

Finally to extract the file system into ROOT you use:

`sudo tar xf NOOBS/os/Raspbian/root.tar.xz -C ROOT`

Again this will take tens of minutes to complete, so time for another break before moving on to the next step.

When this instruction completes you will see the familiar file structure in ROOT.

> Note: If for any reason tar fails to extract the files you can do the job in two steps:

`unxz NOOBS/os/Raspbian/root.tar.xz`

which creates root.tar in the same directory and then

`sudo tar xf NOOBS/os/Raspbian/root.tar -C ROOT`

If you do things this way make sure to remember to delete the intermediate root.tar file. 
 
## 2. Change the files 

This is the easy bit! 
All we have to do is edit the /etc/network/interfaces in the unpacked file system. Assuming that you are using nano:

`sudo nano ROOT/etc/network/interfaces`

and change the file to read:

```
auto lo
iface lo inet loopback
iface eth0 inet dhcp
auto wlan0
allow-hotplug wlan0
iface wlan0 inet dhcp
wpa-ssid "SSID"
wpa-psk "password"
iface default inet dhcp
wireless-power off
```

Save the file and that's job done.

Of course you can make any other changes to configuration files you want to.

If you want to do something like add a package to the OS then it is better to configure a running Raspbian and then copy the file system to ROOT.  

## 3. Repackage and compress
Now we have to convert the file system into a TAR file and then compress it. 
To make a TAR file all we have to do is change directory to ROOT:

`cd /ROOT`

then use the command

`sudo tar cfp root.tar`

Notice the dot at the end of the command - it specifies that the current directory should be used as the source of files for the TAR. Making a TAR is fairly quick so you can move on to the compression.

If you copied the file system from a working Raspbian installation then there are some files you don't need to copy because they are generated by the system and you can save the space. 

Instead of the simple tar command given above use:
``` 
tar -cvpf <label>.tar . --exclude=proc/* 
        --exclude=sys/* --exclude=dev/pts/*
```
The dot says pack everything in the current directory and the excludes say execpt for everything in proc and dev/pts.

As we have already installed xz utilities in Step 1, all we have to do is:

`sudo xz -9 -e root.tar`

This does take a little longer so be patient - yes now is a good time to take another break.
When it is finished you should find root.tar.xz in the ROOT directory ready to be copied into the NOOBS SD card.

## 4. Setup the SD card
Now all you have to do is copy the root.tar.xz file back into the NOOBS/os/Raspbian directory. Assuming you are still in the ROOT directory this would be:

`sudo mv root.tar.xz ../NOOBS/os/Raspbian`

Next you need to edit the partitions.json file to reflect the new file sizes

`nano partitions.json`

You need to specify the partition size and the size of the file that results when you uncompress the tar file. The partition size just has to be big enough to hold the uncompressed file system. The default for Raspbian is:
`   "partition_size_nominal": 2450`

Increase this if necessary. This is the smallest space needed for the file system. 

You also need to set the size of the uncompressed file system. This has to be in MBytes and rounded up. For example, if the root.tar file expands to give a file 1958, 103, 040 bytes then the uncompressed_tarball_size has to be set to 1959. 

The big problem here is finding the size of the uncompressed TAR. You can't simply check the size of the file system you compressed because you might have excluded some files. 

The simplest solution is to use:

`sudo xz -l root.tar.xz`

This lists the size of the uncompressed file. For example:

`Strms Blocks Compressed Uncompressed Ratio`
`1     1      525.8 MiB  1,867.0MiB   0.282 `

So in this case you need to enter:

`"uncompressed_tarball_size": 1867`

Now all that remains is to get the  modified NOOBS files onto an SD card. 

If you are using a real Linux machine with card reader simply write the files in the usual way.

Otherwise the simplest solution is to move the files to a PC or Mac using FTP or preferably SFTP see: Setting up the VM.

Of course if you have a copy of NOOBS on the local machine all you need to do is copy root.tar.xz so that it replaces the existing file.

Now you can use the SD card to install your custom OS.

In the case of this example you can now boot a Pi with a WiFi adaptor plugged in and expect it to connect to the network without you having to do anything much at all.  
