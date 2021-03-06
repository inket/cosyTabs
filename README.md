Safari 5 tabs on Safari 6+. Cosy.

Tested on Safari 6, 7, 8, 9, 10.

Safari 10 was tested under macOS Sierra only.

If you're using an old version of Safari/macOS and you're having problems with the latest version, try the older ones.

### Preview

![After](http://i.imgur.com/sTX1W7j.png)

## How to Install

### macOS Sierra (10.12)

Disable System Integrity Protection, and install the latest version of [mySIMBL](https://github.com/w0lfschild/app_updates/tree/master/mySIMBL).

After that, [download cosyTabs](https://github.com/inket/cosyTabs/releases), extract it, and place `cosyTabs.bundle` in `/Library/Application Support/SIMBL/Plugins/`

Run Safari!

(Feel free to turn SIP back on after this installation, SIMBL will continue to work.)

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

### Note about Safari Technology Preview

I could not get SIMBL to inject into Safari Technology Preview (STP), so STP is unsupported at the moment.

Please create an issue if you have a clue on how to fix this error:

```
Safari Technology Preview[3466:43691] Error loading /System/Library/ScriptingAdditions/SIMBL.osax/Contents/MacOS/SIMBL:  dlopen(/System/Library/ScriptingAdditions/SIMBL.osax/Contents/MacOS/SIMBL, 262): no suitable image found.  Did find:
	/System/Library/ScriptingAdditions/SIMBL.osax/Contents/MacOS/SIMBL: mmap() error 1 at address=0x10AF27000, size=0x00004000 segment=__TEXT in Segment::map() mapping /System/Library/ScriptingAdditions/SIMBL.osax/Contents/MacOS/SIMBL
Safari Technology Preview: OpenScripting.framework - can't find entry point InjectEventHandler in scripting addition /System/Library/ScriptingAdditions/SIMBL.osax.
```

### License
This program is licensed under GNU GPL v3.0 (see LICENSE)
