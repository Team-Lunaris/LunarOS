# vim: set ft=make :
#######################
### custom-system.just
#######################
## Example system configuration commands
## These are simplified examples adapted from Bluefin

# Run a system benchmark (requires stress-ng from Homebrew)
[group('System')]
benchmark:
    #!/usr/bin/env bash
    source /usr/lib/ujust/ujust.sh
    if ! type -P "stress-ng" &>/dev/null ; then
        echo "stress-ng is not installed."
        if command -v brew &>/dev/null; then
            if gum confirm "Install stress-ng via Homebrew?" ; then
                brew install stress-ng
                brew link stress-ng
            else
                exit 0
            fi
        else
            echo "Please install stress-ng to run benchmarks."
            exit 1
        fi
    fi
    echo 'Running a 1 minute benchmark...'
    pushd $(mktemp -d) > /dev/null
    stress-ng --matrix 0 -t 1m --times
    popd > /dev/null

# Configure docker and libvirt groups for development
[group('System')]
configure-dev-groups:
    #!/usr/bin/pkexec bash
    CURRENT_USER="{{ `id -un` }}"
    echo "Adding $CURRENT_USER to docker and libvirt groups..."

    # Ensure groups exist in /etc/group
    for group in docker libvirt; do
        if ! grep -q "^$group:" /etc/group; then
            echo "Adding $group to /etc/group"
            grep "^$group:" /usr/lib/group | tee -a /etc/group > /dev/null
        fi
        usermod -aG $group $CURRENT_USER
    done

    echo "Groups configured. Log out and back in for changes to take effect."

# # Example toggle command with user choice
# [group('System')]
# toggle-example-feature:
#     #!/usr/bin/bash
#     source /usr/lib/ujust/ujust.sh
#     echo "This is an example toggle command."
#     echo "Current status: [check your status here]"
#     OPTION=$(Choose "Enable" "Disable" "Cancel")
#     case "$OPTION" in
#         "Enable")
#             echo "Enabling feature..."
#             # Add your enable logic here
#             ;;
#         "Disable")
#             echo "Disabling feature..."
#             # Add your disable logic here
#             ;;
#         "Cancel")
#             echo "No changes made."
#             ;;
#     esac

# Check for available firmware updates
[group('Maintenance')]
firmware-check:
    #!/usr/bin/bash
    echo "Checking for available firmware updates..."
    fwupdmgr refresh
    fwupdmgr get-updates
    echo "Firmware check complete!"

# Install available firmware updates
[group('Maintenance')]
firmware-update:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    echo "Checking for firmware updates..."
    fwupdmgr refresh
    UPDATES=$(fwupdmgr get-updates)
    if echo "$UPDATES" | grep -q "No updates available"; then
        echo "Your firmware is up to date!"
        exit 0
    fi
    echo "$UPDATES"
    if gum confirm "Install firmware updates?"; then
        echo "Installing firmware updates..."
        sudo fwupdmgr update
        echo "Firmware updates complete! You may need to reboot."
    else
        echo "Firmware update cancelled."
    fi

# View installed firmware versions
[group('System')]
firmware-info:
    #!/usr/bin/bash
    echo "=== Installed Firmware Versions ==="
    echo "BIOS: $(cat /sys/class/dmi/id/bios_version 2>/dev/null || echo 'N/A')"
    echo "EC: $(cat /sys/class/dmi/id/ec_firmware_release 2>/dev/null || echo 'N/A')"
    echo ""
    fwupdmgr get-devices

# Clean up container images and volumes
[group('Maintenance')]
clean-containers:
    #!/usr/bin/bash
    echo "Cleaning up Podman containers, images, and volumes..."
    podman system prune -af
    podman volume prune -f
    echo "Cleanup complete!"

# Update system and reboot if needed
[group('Maintenance')]
update-and-reboot:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    echo "Updating system..."
    sudo bootc upgrade
    if gum confirm "Reboot now to apply updates?"; then
        systemctl reboot
    else
        echo "Reboot later to apply updates."
    fi

# Configure iomem=relaxed kernel parameter for IO Access troubleshooting
[group('Troubleshooting')]
configure-iomem-relaxed:
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    echo "Configuring iomem=relaxed kernel parameter..."

    if rpm-ostree kargs --append=iomem=relaxed; then
        echo "iomem=relaxed parameter configured via rpm-ostree."
        echo "Reboot required for changes to take effect."
        if gum confirm "Reboot now?"; then
            systemctl reboot
        else
            echo "Remember to reboot later to apply kernel parameter changes."
        fi
    else
        echo "Failed to configure kernel parameter via rpm-ostree."
        exit 1
    fi
