#!/usr/bin/env bash
# 💫 https://github.com/sandptel 💫 #

clear

# Display banner
printf "\n%.0s" {1..2}
echo -e "\e[35m
    ╦═╗┌─┐┌─┐┌─┐┬  ┬┌┬┐┬ ┬   ╔╗╔┬─┐ ┬
    ╠╦╝├┤ │ ┬│ ││  │ │ ├─┤───║║║│┌┴┬┘ 2025
    ╩╚═└─┘└─┘└─┘┴─┘┴ ┴ ┴ ┴   ╝╚╝┴┴ └─ 
\e[0m"

# Color definitions
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
RESET="$(tput sgr0)"

# Function definitions (moved to top)
print_separator() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

set -e

# Check for --check argument or existing hardware configuration
skip_to_check=false
if [[ "$1" == "--check" ]]; then
    skip_to_check=true
    echo "$NOTE --check argument detected. Skipping to flake validation..."
elif find hosts/*/hardware.nix -type f 2>/dev/null | grep -q .; then
    echo "$NOTE Existing hardware configuration detected in hosts directory"
    echo "$NOTE You may want to skip the initial setup and go directly to flake validation"
    echo "$NOTE This is useful if you've already configured the system and want to test/rebuild"
    printf "\n"
    read -rp "$CAT Would you like to skip to flake validation check? [y/N]: " skip_choice
    if [[ "$skip_choice" =~ ^[Yy]$ ]]; then
        skip_to_check=true
    fi
fi

if [ "$skip_to_check" = true ]; then
    # Set hostname from existing configuration
    if [ -d "hosts" ]; then
        hostName=$(find hosts -maxdepth 1 -type d ! -name hosts | head -1 | xargs basename 2>/dev/null || echo "regolith")
        echo "$NOTE Using detected hostname: $hostName"
    else
        hostName="regolith"
    fi
    
    # Set Nix experimental features
    export NIX_CONFIG="experimental-features = nix-command flakes"
    
    # Jump to flake validation section
    goto_flake_check() {
        print_separator
        
        # Pre-rebuild configuration review
        echo "$NOTE System Configuration Review Required"
        echo "$NOTE Before proceeding with the system rebuild, please review your configuration:"
        printf "\n"
        echo "$WARN IMPORTANT: Please check line 13 in hosts/$hostName/config.nix"
        echo "$NOTE Review the 'imports' section to include/exclude hardware driver modules"
        echo "$NOTE Check the modules folder for available hardware driver options"
        echo "$NOTE Ensure only the drivers relevant to your hardware are enabled"
        printf "\n"
        echo "$NOTE Also review the kernel configuration section below the hardware drivers"
        echo "$NOTE Verify the kernel version you want to use for your system"
        printf "\n"
        read -rp "$CAT Press Enter after reviewing the configuration files..." -r

        print_separator

        # Flake structure review
        echo "$NOTE Reviewing Flake Structure"
        echo "$NOTE The 'nix flake show' command displays the complete structure of a Nix flake"
        echo "$NOTE This will show all nixosConfigurations, packages, and other outputs available"
        echo "$NOTE In this case, it will present the nixosConfigurations in a tree format"
        printf "\n"
        echo "$NOTE Executing: nix flake show"
        nix flake show
        printf "\n"
        echo "$NOTE The above output shows your current flake structure with available configurations"
        read -rp "$CAT Press Enter after reviewing the flake structure..." -r

        print_separator

        # Optional: Show example flake structure
        echo "$NOTE Optional: Example Flake Structure"
        echo "$NOTE You can also view other flake structures to understand what flakes can contain"
        echo "$NOTE For example, flakes can include modules, packages, devShells, and more"
        echo "$NOTE The regolith-nix flake contains additional components beyond just configurations"
        printf "\n"
        read -rp "$CAT Would you like to see an example flake structure (regolith-lab/regolith-nix)? [y/N]: " show_example
        show_example=${show_example:-N}

        if [[ "$show_example" =~ ^[Yy]$ ]]; then
            echo "$NOTE Executing: nix flake show github:regolith-lab/regolith-nix"
            nix flake show github:regolith-lab/regolith-nix
            printf "\n"
            echo "$NOTE Notice how this flake contains packages, devShells, and other outputs"
            echo "$NOTE Your current flake focuses primarily on nixosConfigurations"
            read -rp "$CAT Press Enter to continue..." -r
        fi

        print_separator

        # Flake validation check
        echo "$NOTE Flake Validation Check"
        echo "$NOTE The 'nix flake check' command evaluates all outputs that the flake generates"
        echo "$NOTE This helps catch configuration errors before running nixos-rebuild switch"
        echo "$NOTE It's much faster than rebuilding the entire system configuration"
        echo "$NOTE This can help identify issues early and save time during troubleshooting"
        printf "\n"
        echo "$NOTE Executing: nix flake check"
        printf "\n"

        if nix flake check; then
            echo "$OK Flake validation completed successfully!"
            echo "$NOTE All flake outputs are valid and can be built"
        else
            echo "$ERROR Flake validation failed!"
            echo "$WARN Please review the error messages above and fix any configuration issues"
            echo "$NOTE Common issues include:"
            echo "      - Syntax errors in .nix files"
            echo "      - Missing or incorrect imports"
            echo "      - Invalid configuration options"
            echo "      - Hardware configuration problems"
            printf "\n"
            read -rp "$CAT Press Enter after fixing the errors to continue, or Ctrl+C to exit..." -r
            printf "\n"
            
            # Re-run flake check after user fixes
            echo "$NOTE Re-running flake validation..."
            if nix flake check; then
                echo "$OK Flake validation now passes!"
            else
                echo "$ERROR Flake validation still failing. Please review and fix all errors."
                exit 1
            fi
        fi

        print_separator

        # System rebuild
        echo "$NOTE Starting NixOS system rebuild..."
        echo "$NOTE This process will rebuild your NixOS system with the new Regolith configuration"
        echo "$NOTE Command to be executed: sudo nixos-rebuild switch --flake .#$hostName"
        echo "$NOTE For more information about nixos-rebuild, visit: https://nixos.wiki/wiki/Nixos-rebuild"
        echo "$NOTE For more information about Flakes, visit: https://nixos.wiki/wiki/Flakes"
        printf "\n"
        echo "$WARN This process may take considerable time depending on:"
        echo "      - Internet connection speed"
        echo "      - System specifications" 
        echo "      - Number of packages to download/compile"
        echo "      - Nix cache availability"
        printf "\n"
        read -rp "$CAT Press Enter to start the system rebuild..." -r

        print_separator

        echo "$NOTE Executing: sudo nixos-rebuild switch --flake .#$hostName"
        if sudo nixos-rebuild switch --flake .#"$hostName"; then
            echo "$OK System rebuild completed successfully!"
        else
            echo "$ERROR System rebuild failed. Please check the error messages above."
            exit 1
        fi

        print_separator
        printf "\n%.0s" {1..2}

        # Check for Regolith configuration files
        if [ ! -f ~/.config/regolith3/Xresources ]; then
            echo "$WARN ⚠️  No default Xresources file found at ~/.config/regolith3/Xresources"
            echo "$NOTE This is required for proper Regolith session functionality"
            echo "$WARN Without proper Xresources configuration, you may experience:"
            echo "      - Session startup errors"
            echo "      - Missing keybindings"
            echo "      - Incorrect theme/appearance settings"
            echo "      - General session instability"
            printf "\n"
            echo "$NOTE A default configuration is available in ./dotfiles/regolith3"
            echo "$NOTE This will copy the configuration files to ~/.config/regolith3"
            printf "\n"
            read -rp "$CAT Would you like to copy the default Regolith configuration files? [Y/n]: " copy_config
            copy_config=${copy_config:-Y}
            
            if [[ "$copy_config" =~ ^[Yy]$ ]]; then
                echo "$NOTE Copying default Regolith configuration..."
                mkdir -p ~/.config/regolith3
                if cp -r ./dotfiles/regolith3/* ~/.config/regolith3/ 2>/dev/null; then
                    echo "$OK Default Regolith configuration copied successfully!"
                else
                    echo "$ERROR Failed to copy configuration files. Please copy manually from ./dotfiles/regolith3"
                fi
            else
                echo "$WARN Configuration files not copied. You will need to set up Xresources manually."
                echo "$NOTE You can copy them later with: cp -r ./dotfiles/regolith3/* ~/.config/regolith3/"
            fi
            
            print_separator
        fi

        # Installation completion check
        if command -v regolith-session-wayland &>/dev/null; then
            printf "\n${OK} 🎉 Installation completed successfully!${RESET}\n\n"
            printf "${NOTE} Start Regolith Session with: regolith-session-wayland${RESET}\n"
            printf "${NOTE} It is highly recommended to reboot your system${RESET}\n\n"

            # Reboot prompt
            read -rp "${CAT} Would you like to reboot now? [y/N]: ${RESET}" reboot_choice

            if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
                echo "Rebooting system..."
                systemctl reboot
            else
                echo "Reboot skipped. Please reboot manually when convenient."
            fi
        else
            printf "\n${WARN} ⚠️  Installation may have failed. Please check the logs...${RESET}\n\n"
            exit 1
        fi
    }
    
    goto_flake_check
    exit 0
fi

# Verification functions
verify_nixos() {
    if [ -n "$(grep -i nixos </etc/os-release)" ]; then
        echo "$OK Verified this is NixOS."
    else
        echo "$ERROR This is not NixOS or the distribution information is not available."
        exit 1
    fi
}

verify_git() {
    if command -v git &>/dev/null; then
        echo "$OK Git is installed, continuing with installation."
    else
        echo "$ERROR Git is not installed. Please install Git and try again."
        echo "Example: nix-shell -p git"
        exit 1
    fi
}

print_separator() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# System verification
verify_nixos
print_separator
verify_git
print_separator

# VM detection and configuration
if hostnamectl | grep -q 'Chassis: vm'; then
    echo "${NOTE} Your system is running on a VM. Enabling guest services..."
    echo "${WARN} Reminder: Please enable 3D acceleration in your VM settings"
    sed -i '/vm\.guest-services\.enable = false;/s/vm\.guest-services\.enable = false;/ vm.guest-services.enable = true;/' hosts/default/config.nix
fi

# NVIDIA GPU detection and configuration
if command -v lspci >/dev/null 2>&1; then
    if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
        echo "${NOTE} NVIDIA GPU detected. Configuring NVIDIA drivers..."
        sed -i '/drivers\.nvidia\.enable = false;/s/drivers\.nvidia\.enable = false;/ drivers.nvidia.enable = true;/' hosts/default/config.nix
    else
        echo "${NOTE} No NVIDIA Graphics Card detected."
    fi
fi

print_separator
echo "$NOTE Default options are shown in brackets [ ]"
echo "$NOTE Press Enter to accept the default value"
sleep 1
print_separator

# Hostname configuration
read -rp "$CAT Enter your new hostname [regolith]: " hostName
hostName=${hostName:-regolith}

print_separator

# Create hostname directory if not default
if [ "$hostName" != "regolith" ]; then
    echo "$NOTE Creating configuration for hostname: $hostName"
    mkdir -p hosts/"$hostName"
    cp hosts/regolith/*.nix hosts/"$hostName"
    git add .
else
    echo "$NOTE Using default hostname: regolith"
fi

print_separator

# Keyboard layout configuration
read -rp "$CAT Enter your keyboard layout [us]: " keyboardLayout
keyboardLayout=${keyboardLayout:-us}

sed -i 's/keyboardLayout\s*=\s*"\([^"]*\)"/keyboardLayout = "'"$keyboardLayout"'"/' ./hosts/$hostName/variables.nix

print_separator

# Username configuration
installusername=$USER
echo "$NOTE Setting username to: $installusername"
sed -i 's/username\s*=\s*"\([^"]*\)"/username = "'"$installusername"'"/' ./flake.nix

print_separator

# Hardware configuration generation
echo "$NOTE Generating hardware configuration..."
attempts=0
max_attempts=3
hardware_file="./hosts/$hostName/hardware.nix"

while [ $attempts -lt $max_attempts ]; do
    if nixos-generate-config --show-hardware-config >"$hardware_file" 2>/dev/null && [ -f "$hardware_file" ]; then
        echo "${OK} Hardware configuration successfully generated"
        break
    else
        attempts=$((attempts + 1))
        echo "${WARN} Hardware configuration generation failed (attempt $attempts/$max_attempts)"

        if [ $attempts -eq $max_attempts ]; then
            echo "${ERROR} Unable to generate hardware configuration after $max_attempts attempts"
            exit 1
        fi
    fi
done

print_separator

# Set Nix experimental features
export NIX_CONFIG="experimental-features = nix-command flakes"

# Regolith session test prompt
echo "$NOTE Testing Regolith Session (Optional)"
echo "$NOTE This will create a development shell for testing Regolith session compatibility"
echo "$NOTE Description: A devshell environment that provides Regolith desktop session"
echo "$NOTE For more information, visit: https://github.com/regolith-lab/regolith-nix"
echo "$WARN CAUTION: This process may take considerable time to download packages"
echo "$WARN and might trigger compilation on your device, depending on cache availability"
read -rp "$CAT Would you like to test regolith-session working on NixOS using a devShell? [y/N]: " test_regolith
test_regolith=${test_regolith:-N}

if [[ "$test_regolith" =~ ^[Yy]$ ]]; then
    echo "$NOTE Starting Regolith session test..."
    echo "$NOTE Press Ctrl+C to exit the session when done testing"
    nix run github:regolith-lab/regolith-nix#regolith-session-wayland
fi

print_separator

# Git configuration for variables.nix
echo "$NOTE Configuring Git settings for the system..."
read -rp "$CAT Enter your Git username [gituser]: " gitUsername
gitUsername=${gitUsername:-gituser}

read -rp "$CAT Enter your Git email [git-email]: " gitEmail
gitEmail=${gitEmail:-git-email}

# Update git settings in variables.nix
sed -i 's/gitUsername\s*=\s*"\([^"]*\)"/gitUsername = "'"$gitUsername"'"/' ./hosts/$hostName/variables.nix
sed -i 's/gitEmail\s*=\s*"\([^"]*\)"/gitEmail = "'"$gitEmail"'"/' ./hosts/$hostName/variables.nix

print_separator

# Final configuration
echo "$NOTE Finalizing configuration..."
git config --global user.name "installer"
git config --global user.email "installer@gmail.com"
git add .
sed -i 's/host\s*=\s*"\([^"]*\)"/host = "'"$hostName"'"/' ./flake.nix

print_separator
printf "\n%.0s" {1..2}

# Pre-rebuild configuration review
echo "$NOTE System Configuration Review Required"
echo "$NOTE Before proceeding with the system rebuild, please review your configuration:"
printf "\n"
echo "$WARN IMPORTANT: Please check line 13 in hosts/$hostName/config.nix"
echo "$NOTE Review the 'imports' section to include/exclude hardware driver modules"
echo "$NOTE Check the modules folder for available hardware driver options"
echo "$NOTE Ensure only the drivers relevant to your hardware are enabled"
printf "\n"
echo "$NOTE Also review the kernel configuration section below the hardware drivers"
echo "$NOTE Verify the kernel version you want to use for your system"
printf "\n"
read -rp "$CAT Press Enter after reviewing the configuration files..." -r

print_separator

# Flake structure review
echo "$NOTE Reviewing Flake Structure"
echo "$NOTE The 'nix flake show' command displays the complete structure of a Nix flake"
echo "$NOTE This will show all nixosConfigurations, packages, and other outputs available"
echo "$NOTE In this case, it will present the nixosConfigurations in a tree format"
printf "\n"
echo "$NOTE Executing: nix flake show"
nix flake show
printf "\n"
echo "$NOTE The above output shows your current flake structure with available configurations"
read -rp "$CAT Press Enter after reviewing the flake structure..." -r

print_separator

# Optional: Show example flake structure
echo "$NOTE Optional: Example Flake Structure"
echo "$NOTE You can also view other flake structures to understand what flakes can contain"
echo "$NOTE For example, flakes can include modules, packages, devShells, and more"
echo "$NOTE The regolith-nix flake contains additional components beyond just configurations"
printf "\n"
read -rp "$CAT Would you like to see an example flake structure (regolith-lab/regolith-nix)? [y/N]: " show_example
show_example=${show_example:-N}

if [[ "$show_example" =~ ^[Yy]$ ]]; then
    echo "$NOTE Executing: nix flake show github:regolith-lab/regolith-nix"
    nix flake show github:regolith-lab/regolith-nix
    printf "\n"
    echo "$NOTE Notice how this flake contains packages, devShells, and other outputs"
    echo "$NOTE Your current flake focuses primarily on nixosConfigurations"
    read -rp "$CAT Press Enter to continue..." -r
fi

print_separator

# Flake validation check
echo "$NOTE Flake Validation Check"
echo "$NOTE The 'nix flake check' command evaluates all outputs that the flake generates"
echo "$NOTE This helps catch configuration errors before running nixos-rebuild switch"
echo "$NOTE It's much faster than rebuilding the entire system configuration"
echo "$NOTE This can help identify issues early and save time during troubleshooting"
printf "\n"
echo "$NOTE Executing: nix flake check"
printf "\n"

if nix flake check; then
    echo "$OK Flake validation completed successfully!"
    echo "$NOTE All flake outputs are valid and can be built"
else
    echo "$ERROR Flake validation failed!"
    echo "$WARN Please review the error messages above and fix any configuration issues"
    echo "$NOTE Common issues include:"
    echo "      - Syntax errors in .nix files"
    echo "      - Missing or incorrect imports"
    echo "      - Invalid configuration options"
    echo "      - Hardware configuration problems"
    printf "\n"
    read -rp "$CAT Press Enter after fixing the errors to continue, or Ctrl+C to exit..." -r
    printf "\n"
    
    # Re-run flake check after user fixes
    echo "$NOTE Re-running flake validation..."
    if nix flake check; then
        echo "$OK Flake validation now passes!"
    else
        echo "$ERROR Flake validation still failing. Please review and fix all errors."
        exit 1
    fi
fi

print_separator

# System rebuild
echo "$NOTE Starting NixOS system rebuild..."
echo "$NOTE This process will rebuild your NixOS system with the new Regolith configuration"
echo "$NOTE Command to be executed: sudo nixos-rebuild switch --flake .#$hostName"
echo "$NOTE For more information about nixos-rebuild, visit: https://nixos.wiki/wiki/Nixos-rebuild"
echo "$NOTE For more information about Flakes, visit: https://nixos.wiki/wiki/Flakes"
printf "\n"
echo "$WARN This process may take considerable time depending on:"
echo "      - Internet connection speed"
echo "      - System specifications" 
echo "      - Number of packages to download/compile"
echo "      - Nix cache availability"
printf "\n"
read -rp "$CAT Press Enter to start the system rebuild..." -r

print_separator

echo "$NOTE Executing: sudo nixos-rebuild switch --flake .#$hostName"
if sudo nixos-rebuild switch --flake .#"$hostName"; then
    echo "$OK System rebuild completed successfully!"
else
    echo "$ERROR System rebuild failed. Please check the error messages above."
    exit 1
fi

print_separator
printf "\n%.0s" {1..2}

# Check for Regolith configuration files
if [ ! -f ~/.config/regolith3/Xresources ]; then
    echo "$WARN ⚠️  No default Xresources file found at ~/.config/regolith3/Xresources"
    echo "$NOTE This is required for proper Regolith session functionality"
    echo "$WARN Without proper Xresources configuration, you may experience:"
    echo "      - Session startup errors"
    echo "      - Missing keybindings"
    echo "      - Incorrect theme/appearance settings"
    echo "      - General session instability"
    printf "\n"
    echo "$NOTE A default configuration is available in ./dotfiles/regolith3"
    echo "$NOTE This will copy the configuration files to ~/.config/regolith3"
    printf "\n"
    read -rp "$CAT Would you like to copy the default Regolith configuration files? [Y/n]: " copy_config
    copy_config=${copy_config:-Y}
    
    if [[ "$copy_config" =~ ^[Yy]$ ]]; then
        echo "$NOTE Copying default Regolith configuration..."
        mkdir -p ~/.config/regolith3
        if cp -r ./dotfiles/regolith3/* ~/.config/regolith3/ 2>/dev/null; then
            echo "$OK Default Regolith configuration copied successfully!"
        else
            echo "$ERROR Failed to copy configuration files. Please copy manually from ./dotfiles/regolith3"
        fi
    else
        echo "$WARN Configuration files not copied. You will need to set up Xresources manually."
        echo "$NOTE You can copy them later with: cp -r ./dotfiles/regolith3/* ~/.config/regolith3/"
    fi
    
    print_separator
fi

# Installation completion check
if command -v regolith-session-wayland &>/dev/null; then
    printf "\n${OK} 🎉 Installation completed successfully!${RESET}\n\n"
    printf "${NOTE} Start Regolith Session with: regolith-session-wayland${RESET}\n"
    printf "${NOTE} It is highly recommended to reboot your system${RESET}\n\n"

    # Reboot prompt
    read -rp "${CAT} Would you like to reboot now? [y/N]: ${RESET}" reboot_choice

    if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
        echo "Rebooting system..."
        systemctl reboot
    else
        echo "Reboot skipped. Please reboot manually when convenient."
    fi
else
    printf "\n${WARN} ⚠️  Installation may have failed. Please check the logs...${RESET}\n\n"
    exit 1
fi
