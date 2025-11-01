#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Star Labs Firmware Support
###############################################################################
# Installs fwupd, flashrom, and GNOME Firmware for Star Labs laptop support
# Enables LVFS (Linux Vendor Firmware Service) for OEM firmware updates
###############################################################################

echo "::group:: Install Firmware Update Tools"

dnf5 install -y \
    fwupd \
    flashrom \
    gnome-firmware

echo "::endgroup::"

echo "::group:: Configure Firmware Services"

# Enable fwupd daemon
systemctl enable fwupd

echo "::endgroup::"

echo "Firmware support installation complete!"
