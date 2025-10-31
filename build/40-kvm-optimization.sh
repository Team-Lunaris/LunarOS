#!/usr/bin/bash
set -eoux pipefail

###############################################################################
# KVM/QEMU Windows VM Performance Optimization
###############################################################################
# Installs performance tuning tools and kernel parameters for better VM FPS
###############################################################################

echo "::group:: Install KVM Performance Tools"

dnf5 install -y \
    qemu-guest-agent \
    tuned \
    tuned-profiles-cpu-partitioning \
    sysstat

echo "::endgroup::"

echo "::group:: Enable Kernel Parameters for Better VM Performance"

# Enable KVM polling for lower latency (critical for Windows VM FPS)
cat >> /etc/modprobe.d/kvm-optimization.conf << 'EOF'
# KVM poll period in nanoseconds - set to poll for 50us before exiting
options kvm_intel ple_gap=0
options kvm_amd ple_gap=0

# Enable polling for halt loops (guest halt polling) - significant FPS boost
options kvm poll_ns=50000

# Tuning for nested virtualization
options kvm_intel enable_shadow_vmcs=1
options kvm_intel enable_apicv=1
options kvm_intel nested=1
EOF

echo "::endgroup::"

echo "::group:: Create TuneD Profile for VM Host"

mkdir -p /etc/tuned/lunaros-vm-host/

cat > /etc/tuned/lunaros-vm-host/tuned.conf << 'EOF'
[main]
summary=LunarOS optimized profile for KVM host
include=cpu-partitioning

[cpu]
force_latency=cstate.menu:LATENCY_C1

[vm]
# Reduce swap usage
vm.swappiness=10
# Better VM performance
vm.dirty_ratio=20
vm.dirty_background_ratio=10

[sysctl]
# Reduce jitter
kernel.sched_migration_cost_ns=5000000
EOF

# Set the profile (optional - users can enable with: tuned-adm profile lunaros-vm-host)
# tuned-adm profile lunaros-vm-host

echo "::endgroup::"

echo "KVM optimization complete!"
