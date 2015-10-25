Safari 5 tabs on Safari 6+. Cosy.

Tested on Safari 6, 7, 8, 9.

Safari 9 was tested under El Capitan and Yosemite.

If you're using an old version of Safari/OS X and you're having problems with the latest version, try the older ones.

### Preview

![After](http://i.imgur.com/sTX1W7j.png)

## How to Install

### El Capitan (OS X 10.11)

EasySIMBL does not work anymore because of the [System Integrity Protection](https://en.wikipedia.org/wiki/System_Integrity_Protection) introduced in El Capitan.

It has been confirmed that the old SIMBL-0.9.9 works, but only after disabling SIP.

Here's the guide for installing SIMBL on El Capitan: https://github.com/norio-nomura/EasySIMBL/issues/26#issuecomment-117028426

After that, [download cosyTabs](https://github.com/inket/cosyTabs/releases), extract it, and place `cosyTabs.bundle` in `/Library/Application Support/SIMBL/Plugins/`

##### For advanced users

Obviously, there is no need to disable SIP (and reboot 4+ times). If you can extract SIMBL from the .pkg, boot into Recovery or any other OS, then you can simply copy the SIMBL's files to the correct paths.

### OS X 10.10.4+ (Updated Yosemite)

1. Download and install [SIMBL-0.9.9](http://www.culater.net/software/SIMBL/SIMBL.php)
2. Download cosyTabs here: [Releases](https://github.com/inket/cosyTabs/releases)
3. Extract it, and place `cosyTabs.bundle` in `/Library/Application Support/SIMBL/Plugins/`

### OS X 10.7 → 10.10.3

1. Download and install [EasySIMBL](https://github.com/norio-nomura/EasySIMBL/#how-to-install)
2. Download cosyTabs here: [Releases](https://github.com/inket/cosyTabs/releases)
3. Extract & Install cosyTabs:
	- Open EasySIMBL and drag & drop *cosyTabs.bundle* into the list.

### License
This program is licensed under GNU GPL v3.0 (see LICENSE)