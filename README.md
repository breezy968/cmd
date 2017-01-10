##Control Multiple Devices with shell
===
  This model is a shell script for operating multiple Android devices with adb or fastboot command at once.
  
## Requirements

* [ADB](http://developer.android.com/tools/help/adb.html) properly set up
* USB hubs

##Usage
  For example,you can wakeup all the devices by following command.
```bash
./cmd adb shell input keyevent 82
```
