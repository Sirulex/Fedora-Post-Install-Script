fixBrightnessControl () {

# Check if the file /etc/default/grub exists
if [ ! -f /etc/default/grub ]; then
    echo "The file /etc/default/grub was not found."
    exit 1
fi

# Check if the line with GRUB_CMDLINE_LINUX already exists
if grep -q '^GRUB_CMDLINE_LINUX=' /etc/default/grub; then
    # Check if acpi_backlight is already present in the variable
    if grep -q 'acpi_backlight=' /etc/default/grub; then
        echo "The variable GRUB_CMDLINE_LINUX already contains the entry 'acpi_backlight'."
        echo -e "Nothing was changed regarding Laptop Brightness Control\n"
    else
        # Parameter acpi_backlight is not yet present in the variable, so add it
        sed -i '/^GRUB_CMDLINE_LINUX=/ s/"$/ acpi_backlight=native"/' /etc/default/grub
        echo "The entry 'acpi_backlight=native' has been added to the variable GRUB_CMDLINE_LINUX."
        # Grub reload Config
        sudo grub2-mkconfig -o /boot/grub2/grub.cfg
        echo -e "Laptop Brightness Control Fix applied\n"
    fi
else
    # The line with GRUB_CMDLINE_LINUX does not exist, so add it
    echo 'GRUB_CMDLINE_LINUX="acpi_backlight=native"' >> /etc/default/grub
    echo "The line 'GRUB_CMDLINE_LINUX' has been added to the file /etc/default/grub."
    # Grub reload Config
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    echo -e "Laptop Brightness Control Fix applied\n"
fi

}

libInputConfig () {
  echo "Installing LibInput-Config"
  
  local target_directory="/opt/LibInput-Config"

  # Check if the repository has already been cloned
  if [ -d "$target_directory" ]; then
      echo "The repository has already been cloned. Navigating into /opt/LibInput-Config"
      cd "$target_directory"
  else
      echo "The repository has not been cloned yet. Cloning it now..."
      cd /opt
      git clone https://gitlab.com/warningnonpotablewater/libinput-config.git
      mv libinput-config "$target_directory"
      cd "$target_directory"
  fi

  #Install Dependencies (Fedora)
  sudo dnf install libinput-devel systemd-devel meson

  #Make Config File

  # Path to the target configuration file
  local config_file="/etc/libinput.conf"

  # Check if the file exists and contains a value
  if [ -f "$config_file" ] && grep -q "^scroll-factor=" "$config_file"; then
      echo "The file $config_file already exists and contains a value."
      read -p "Do you want to overwrite the value? (y/n): " overwrite
      if [ "$overwrite" != "y" ]; then
          echo "Aborted. Scrollfactor was not changed."
          return
      fi
  fi

  # Prompt the user for the value
  read -p "Enter the new value for scroll-factor (e.g. 0.3): " value

  # Write the value to the configuration file
  echo "scroll-factor=$value" > "$config_file"

  echo "The value has been successfully written to the file $config_file."

  #Build Ressources
  meson build
  cd build
  # meson configure -Dnon_glibc=true
  # meson configure -Dshitty_sandboxing=true
  ninja
  sudo ninja install
  echo -e "Laptop Touchpad Scroll Speed has been changed successfully. Changes won't be effective until a system restart or relogin.\n"
}

toggleFractionalScaling() {

    local scaling_enabled=$(sudo -u $SUDO_USER gsettings get org.gnome.mutter experimental-features | grep -o 'scale-monitor-framebuffer' | wc -l)
    
    if [ "$scaling_enabled" -eq 0 ]; then
        echo "Fractional scaling is currently disabled. Would you like to enable it? (y/n)"
        read -r enable_scaling
        if [ "$enable_scaling" = "y" ]; then
            sudo -u $SUDO_USER gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
            echo "Fractional scaling has been enabled."
        else
            echo "Fractional scaling remains disabled."
        fi
    else
        echo "Fractional scaling is currently enabled. Would you like to disable it? (y/n)"
        read -r disable_scaling
        if [ "$disable_scaling" = "y" ]; then
            sudo -u $SUDO_USER gsettings reset org.gnome.mutter experimental-features
            echo "Fractional scaling has been disabled."
        else
            echo "Fractional scaling remains enabled."
        fi
    fi
}

installAutoCpuFreq () {
  cd /opt
  git clone https://github.com/AdnanHodzic/auto-cpufreq.git
  chmod +x ./auto-cpufreq/auto-cpufreq-installer
  sudo ./auto-cpufreq/auto-cpufreq-installer
  echo "Installed Auto-CPU-Freq"
}

echo -e "\nFedora Post-Install Script made by Sirulex\n"

if [ "$EUID" -ne 0 ]; then
    echo -e "Make sure the script is executed with sudo\n"
    exit
fi

#local initial_directory=$(pwd)

while true; do

  PS3=$'\nPlease select an option: '

  select opt in "Fix Laptop Brightness Control (Kernel Parameter)" "Change System Time Format to RTC (Dualboot)" "Fix Touchpad Scroll Speed (libinput-config)" "Toggle Fractional Scaling (Gnome/Mutter)" "Install Auto-CPU-Freq (Increase Battery Life)" Quit; do

    case $REPLY in
      1)
        fixBrightnessControl ;;
      2)
        echo "Changing system time format to RTC"
        timedatectl set-local-rtc 1 --adjust-system-clock ;;
      3)
        libInputConfig;;
      4)
        toggleFractionalScaling;;
      5)
        installAutoCpuFreq ;;
      6)
        echo -e "Quitting - Thanks for using the script.\n"    
        exit;;
      *) 
        echo "Invalid option $REPLY";;
    esac

    echo ""
    break
    
  done
done




