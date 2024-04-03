<h1 align="center">
  Fedora Post Install Script
</h1> 

#### Note: This script is primarily targeted for Fedora GNOME

###### I created this script to get basic functionality working for my Lenovo-Laptop (Slim-7-Pro)
Feel free to update this script to your liking or report any bugs you encounter

## How to run?

1. Make sure `git` is usable<br>
   If not, install it:

```sh
sudo dnf install git -y
```

2. Open Terminal, type:

```sh
git clone https://github.com/Sirulex/Fedora-Post-Install-Script.git
cd ./Fedora-Post-Install-Script
```

3. Run the script:

```sh
chmod u+x ./Fedora-Post-Install.sh
./Fedora-Post-Install.sh
```

## Functionalities of this script
1. Fix the backlight control for this device by adding a kernel parameter (acpi_backlight)
2. Changing system time format to RTC to have consistent time in both Linux and Windows (for dualboot scenarios)
3. Fix Touchpad Scroll Speed by installing libinput-config and changing the calculation factor for swipe inputs
4. Toggle Fractional Scaling (Gnome/Mutter) as GNOME does not allow changing this setting through its GUI (especially useful for HiDPI Screens)
5. Install Auto-CPU-Freq to increase battery life. This tool optimizes the core clocks and power profiles of the CPU (and much more) to reduce power draw.