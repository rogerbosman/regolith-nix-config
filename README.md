# Regolith Desktop on NixOS - Starter Configuration

> A complete NixOS configuration for the Regolith desktop environment with automated installation and setup.

## Preview 
![regolith-preview on nixos](https://github.com/user-attachments/assets/48bb7bfe-44c3-4c5c-8e07-11f96b7bc367)

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [What the Install Script Does?](#what-the-install-script-does)
- [NixOS Commands Reference](#nixos-commands-reference)
- [Configuration Management](#configuration-management)
- [Hardware Configuration](#hardware-configuration)
- [Troubleshooting](#troubleshooting)

## Overview

This repository provides a streamlined way to install and configure Regolith desktop environment on NixOS using Nix Flakes. The installation script automates the entire process from hardware detection to system rebuild.

### Features

- Automated installation with interactive prompts
- Hardware detection and configuration (VM, NVIDIA)
- Pre-configured Regolith themes and settings
- Flake-based configuration management
- Fast rebuild and testing capabilities

## Installation

### Quick Start

```bash
# Clone the repository
git clone <repository-url>
cd regolith-starter-configs

# Run the installation script
./install.sh
```

### Advanced Usage

```bash
# Skip to flake validation (if already configured)
./install.sh --check
```

## What the Install Script Does?

### 1. Initial System Verification

The installation script performs automated checks and configurations:

- **System Verification**: Confirms NixOS environment and Git availability
- **Hardware Detection**: Automatically detects and configures:
  - Virtual Machine settings (enables guest services)
  - NVIDIA GPU drivers (if detected)
- **Configuration Prompts**: Interactive setup for:
  - Hostname configuration
  - Keyboard layout selection
  - Username configuration
  - Git credentials setup

### 2. Hardware Configuration Generation

```bash
# The script automatically generates hardware configuration
nixos-generate-config --dir ./hosts/your-hostname/
```

> **Note**: You can also copy hardware configuration from existing NixOS installations located at `/etc/nixos/hardware-configuration.nix`

### 3. Pre-rebuild Configuration Review

The script pauses for manual review of critical configuration files:

- **Hardware Drivers**: Review line 13 in `hosts/hostname/config.nix` imports section
- **Kernel Configuration**: Verify kernel version settings below hardware drivers
- **Module Selection**: Check modules folder for available hardware driver options

### 4. Flake Structure Analysis

#### Display Flake Structure
```bash
# Shows the complete flake structure
nix flake show
```

This command displays:
- Available NixOS configurations in tree format
- System packages and modules
- Development shells and other outputs

#### Optional Example Review
```bash
# Optional: View example flake structure
nix flake show github:regolith-lab/regolith-nix
```

Shows additional flake components like packages, devShells, and modules beyond configurations.

### 5. Flake Validation Process

#### Comprehensive Validation Check
```bash
# Validates all flake outputs
nix flake check
```

**Benefits of `nix flake check`:**
- Catches configuration errors before system rebuild
- Much faster than full system rebuild
- Prevents broken system states
- Identifies syntax and configuration issues early

**Process Flow:**
- Runs initial validation
- If errors found: prompts user to fix issues and re-validates
- If validation fails twice: exits with error
- Only proceeds to rebuild after successful validation

### 6. System Rebuild Phase

After successful validation:

```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

**Process Details:**
- Provides links to documentation (nixos-rebuild and Flakes wikis)
- Warns about time-consuming nature of rebuild
- Lists factors affecting rebuild time (internet speed, system specs, cache availability)
- Waits for user confirmation before proceeding

### 7. Post-rebuild Configuration Check

#### Regolith Configuration Validation
- **Checks**: Verifies existence of `~/.config/regolith3/Xresources`
- **Warning**: Explains potential session issues without proper Xresources
- **Solution**: Offers to copy default configuration from `./dotfiles/regolith3/`

#### Installation Completion
- **Verification**: Confirms `regolith-session-wayland` command availability
- **Information**: Provides future rebuild commands
- **Session Info**: Explains login entries and Work-In-Progress sessions
- **Reboot**: Recommends system reboot for optimal performance

## NixOS Commands Reference

### Essential Commands

#### System Rebuild
```bash
# Apply configuration changes permanently
sudo nixos-rebuild switch --flake .#your-hostname

# Test configuration without permanent changes
sudo nixos-rebuild test --flake .#your-hostname

# Build configuration without activation
sudo nixos-rebuild build --flake .#your-hostname
```

#### Flake Management
```bash
# Show flake structure and outputs
nix flake show

# Validate all flake outputs
nix flake check

# Update flake inputs
nix flake update

# update specific input
nix flake update <input-name>

# Update Regolith input
nix flake update regolith 

# Show flake metadata
nix flake metadata
```

#### System Information
```bash
# Check current system generation
nixos-rebuild list-generations

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Boot into specific generation
sudo nixos-rebuild switch --switch-generation <number>
```

## Configuration Management

### Directory Structure

```
regolith-starter-configs/
├── flake.nix              # Main flake configuration
├── hosts/
│   └── your-hostname/
│       ├── config.nix     # System configuration
│       ├── hardware.nix   # Hardware-specific settings
│       └── variables.nix  # User variables
├── modules/               # Reusable NixOS modules
├── dotfiles/
│   └── regolith3/        # Regolith configuration files
└── install.sh            # Installation script
```

### Making Configuration Changes

1. **Edit Configuration Files**:
   ```bash
   # Edit main system configuration
   nano hosts/your-hostname/config.nix
   
   # Edit user variables
   nano hosts/your-hostname/variables.nix
   ```

2. **Validate Changes**:
   ```bash
   nix flake check
   ```

3. **Apply Changes**:
   ```bash
   sudo nixos-rebuild switch --flake .#your-hostname
   ```

### Key Configuration Files

#### `hosts/your-hostname/config.nix`
- Line 13: Hardware driver imports (review and modify as needed)
- You can choose you own kernel package: https://nixos.wiki/wiki/Linux_kernel
- System-wide packages and services : https://search.nixos.org/options?show=environment.systemPackages

#### `hosts/your-hostname/variables.nix`
- User-specific settings
- Git configuration
- Keyboard layout
- Personal preferences

## Hardware Configuration

### Automatic Generation

The script automatically generates hardware configuration using:

```bash
nixos-generate-config --dir ./hosts/your-hostname/
```

### Manual Configuration

If you have an existing NixOS installation, you can copy the hardware configuration:

```bash
# Copy from existing NixOS installation
cp /etc/nixos/hardware-configuration.nix ./hosts/your-hostname/hardware.nix
```

### Hardware-Specific Settings

- **NVIDIA GPUs**: Automatically enabled when detected
- **Virtual Machines**: Guest services enabled automatically
- **Custom Hardware**: Modify `hardware.nix` as needed

## Using Regolith

### Starting Regolith Session

After installation and reboot:

1. **Login Screen**: Look for "Regolith Wayland" entry
2. **Alternative Sessions**: Two additional WIP sessions may be available
3. **First Login**: Default keybindings and themes are pre-configured

### Default Keybindings

Regolith uses i3-style keybindings with Super key as modifier. Configuration files are located in `~/.config/regolith3/`.

## Troubleshooting

### Common Issues

#### Flake Check Failures
```bash
# Common causes and solutions:
# - Syntax errors in .nix files
# - Missing or incorrect imports
# - Invalid configuration options
# - Hardware configuration problems

# Re-run validation after fixes
nix flake check
```

#### System Rebuild Failures
```bash
# Check system journal for errors
journalctl -xe

# Rollback to previous working generation
sudo nixos-rebuild switch --rollback
```

#### Session Issues
```bash
# Ensure Regolith configuration exists
ls ~/.config/regolith3/

# Copy default configuration if missing
cp -r ./dotfiles/regolith3/* ~/.config/regolith3/
```

### Getting Help

- **NixOS Wiki**: [https://nixos.wiki/](https://nixos.wiki/)
- **Flakes Documentation**: [https://nixos.wiki/wiki/Flakes](https://nixos.wiki/wiki/Flakes)
- **nixos-rebuild Guide**: [https://nixos.wiki/wiki/Nixos-rebuild](https://nixos.wiki/wiki/Nixos-rebuild)
- **Regolith Documentation**: [https://regolith-desktop.com/](https://regolith-desktop.com/)
- **Begineer Handbook**: [https://github.com/kstenerud/nixos-beginners-handbook](https://github.com/kstenerud/nixos-beginners-handbook)
- **Zero to Nix**: [https://zero-to-nix.com/](https://zero-to-nix.com/)

## Notes

- **First Time Users**: The installation process may take considerable time depending on internet speed and system specifications
- **System Requirements**: Ensure adequate disk space for package downloads and compilation
- **Backup**: Always backup important data before system modifications
- **Reboot Recommended**: Reboot after installation for optimal performance

---

**Enjoy your Regolith desktop environment on NixOS!**
