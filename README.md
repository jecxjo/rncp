rncp / Ruby Network Copy
====

This project is a port of Pyncp which is a port of the original 
"ncp - a fast file copy tool for LANs" originally written by Felix von
Leitner <felix-ncp@fefe.de>

At the moment rncp seems to be compatible with pyncp's default settings
(i.e. Multicast for poll/push and gzip compression) but all options 
will eventually be implemented via command line arguments. Also, all
code should be pure ruby (minitar and Glib gems) so it should work with
most if not all OS's.

Installation
------------

Install ruby, then install the gem:

    $ gem install rncp

Its a pure ruby gem, depending on pure ruby gems, so it should work with 
most rubies.

Quick Start
-----------

If you want to send a file, directory or group of files/directories, start
the listener on the destination machine:

    $ rncp

To send a file or directory directly:

    $ rncp send 192.168.1.2 file.txt ./directory

To send files and directories without knowing IP Addresses or Hostnames 
setup a Multicast/Broadcast Poll on the destination machine:

    $ rncp poll

To send via Multicast/Broadcast use a push:

    $ rncp push file.txt ./directory

Credits
-------
Thanks to [Felix](http://www.fefe.de/ncp/) and
[makefu](https://github.com/makefu/pyncp)
