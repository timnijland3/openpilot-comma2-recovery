OpenPilot Comma2 revival
======

Well! You got your hands on the mighty Comma2, but need NEOS reinstalled?
I got you covered! Atleast, hopefully :D

Requirements
------
1. A Windows PC with Administrative permissions
2. A (USB-A or USB-C) to USB-C cable
2. Comma 2 in Fastboot mode (holding `Power + Volume -` when plugging in USB-C cable)
3. Have ADB installed (so you can see the Comma2 device in Fastboot mode `fastboot devices` )


Reflashing NEOS for Comma2
------
1. All requirements above are met
2. Download and extract this repository
3. In the repository folder open the `start.bat` file
4. The flashing progress of NEOS will start for the Comma2 (This can take up to 5 minutes)

Working around the "The Network xxx is not connected to the internet." issue.
------

Troubleshooting
------
- Device does not show with `fastboot devices`
    1. Comma2 is not in Fastboot Mode (holding `Power + Volume -` when plugging in USB-C cable)
    2. Within Device Manager (`Windows + X`), Android is shown as "Other Device" instead of "Android Device > Android Composite ADB Interface" you can fix this by running Fawaz Ahmed's Installer: https://github.com/fawazahmed0/Latest-adb-fastboot-installer-for-windows
