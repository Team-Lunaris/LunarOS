# Windows 11 VM Optimization Commands

[group('Virtualization')]
@windows11-vm-optimization:
    #!/usr/bin/bash
    echo "Windows 11 VM Performance Optimization Guide"
    echo "=============================================="
    echo ""
    echo "CRITICAL: Use these settings when creating a Windows 11 VM in virt-manager:"
    echo ""
    echo "1. MEMORY & CPU ALLOCATION (for 22-core system):"
    echo "   ✓ RAM: Allocate 8-16 GB (not too much - affects boot time)"
    echo "   ✓ CPUs: Use 8-10 cores MAX (leave 6+ for host)"
    echo "   ✓ CPU Topology: 1 socket, 8 cores, 1 thread (NOT multiple sockets)"
    echo ""
    echo "2. STORAGE:"
    echo "   ✓ Disk bus: VirtIO (not SATA)"
    echo "   ✓ Format: qcow2 on fast SSD"
    echo ""
    echo "3. NETWORK:"
    echo "   ✓ Model: VirtIO"
    echo ""
    echo "4. DISPLAY:"
    echo "   ✓ Model: Spice or Virtio"
    echo "   ✓ Video RAM: 256 MB minimum"
    echo ""
    echo "5. FIRMWARE & SECURITY:"
    echo "   ✓ Firmware: UEFI (OVMF)"
    echo "   ✓ Enable Secure Boot: YES"
    echo "   ✓ Add TPM: YES (for Windows 11)"
    echo ""
    echo "6. ADVANCED (Edit XML after VM creation):"
    echo "   ✓ CPU Mode: host-passthrough or host-model"
    echo "   ✓ Add CPU enlightenments: Hyper-V"
    echo "   ✓ Add I/O threads: 2"
    echo "   ✓ Add hugepages: YES"
    echo ""
    echo "IMPORTANT: After VM creation, edit with virsh:"
    echo "  virsh edit <vm-name>"
    echo ""
    echo "Then see: show-win11-xml-template"
    echo ""

[group('Virtualization')]
@show-win11-xml-template:
    #!/usr/bin/bash
    echo "Optimized Windows 11 VM XML Template"
    echo "====================================="
    echo ""
    echo "Add these sections to your Windows 11 VM XML configuration:"
    echo ""
    cat << 'EOF'
<!-- Edit with: virsh edit win11-vm-name -->

<!-- CRITICAL: Update CPU section for your system -->
<cpu mode='host-passthrough' check='none'>
  <topology sockets='1' dies='1' cores='8' threads='1'/>
  <!-- Hyper-V enlightenments - CRITICAL for Windows performance -->
  <feature policy='require' name='invtsc'/>
  <feature policy='optional' name='hyperv_time'/>
  <feature policy='optional' name='hyperv_relaxed'/>
  <feature policy='optional' name='hyperv_vapic'/>
  <feature policy='optional' name='hyperv_spinlocks'/>
  <feature policy='optional' name='hyperv_vpindex'/>
  <feature policy='optional' name='hyperv_runtime'/>
  <feature policy='optional' name='hyperv_synic'/>
  <feature policy='optional' name='hyperv_stimer'/>
  <feature policy='optional' name='hyperv_reenlightenment'/>
  <feature policy='optional' name='hyperv_tlbflush'/>
  <feature policy='optional' name='hyperv_ipi'/>
  <feature policy='optional' name='hyperv_evmcs'/>
</cpu>

<!-- Add I/O threads for better disk performance -->
<iothreads>2</iothreads>
<iothreadids>
  <iothread id='1'/>
  <iothread id='2'/>
</iothreadids>

<!-- Memory settings for performance -->
<memory unit='KiB'>12582912</memory>
<currentMemory unit='KiB'>12582912</currentMemory>
<memoryBacking>
  <hugepages>
    <page size='2048' unit='KiB' nodeset='0'/>
  </hugepages>
  <locked/>
</memoryBacking>

<!-- Video device optimization -->
<video>
  <model type='virtio' vram='262144' heads='1'/>
</video>

<!-- Enable SPICE graphics protocol (better than VNC) -->
<graphics type='spice' port='5900' autoport='yes'>
  <listen type='address'/>
</graphics>
EOF
    echo ""
    echo "Tips:"
    echo "  • Adjust <cores> to match your CPU (8-10 recommended)"
    echo "  • Allocate proper <memory> (8-16 GB typical)"
    echo "  • After applying, reboot the VM"
    echo "  • Install VirtIO drivers in Windows for disk/network"
    echo ""

[group('Virtualization')]
@install-virtio-windows:
    #!/usr/bin/bash
    echo "Installing VirtIO drivers in Windows VM"
    echo "========================================"
    echo ""
    echo "1. Download ISO:"
    echo "   wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/latest-virtio/virtio-win.iso"
    echo ""
    echo "2. In virt-manager:"
    echo "   • Right-click VM → Open"
    echo "   • Click CD/DVD → Browse → Select virtio-win.iso"
    echo "   • Boot Windows"
    echo ""
    echo "3. In Windows Device Manager:"
    echo "   • Find yellow exclamation marks (missing drivers)"
    echo "   • Right-click → Update Driver"
    echo "   • Browse to D: (CD drive) → virtio drivers"
    echo "   • Restart Windows"
    echo ""
    echo "4. Verify in Device Manager:"
    echo "   • Red Hat VirtIO SCSI controller (disk)"
    echo "   • Red Hat VirtIO Ethernet Adapter (network)"
    echo ""

[group('Virtualization')]
@check-kvm-status:
    #!/usr/bin/bash
    echo "Checking KVM virtualization support..."
    echo ""
    
    # Check for virtualization capability
    if egrep -c '(vmx|svm)' /proc/cpuinfo &>/dev/null; then
        echo "✓ CPU supports virtualization (VT-x or AMD-V)"
    else
        echo "✗ CPU does NOT support virtualization - check BIOS settings"
        exit 1
    fi
    
    # Check for KVM module
    if lsmod | grep -q kvm; then
        echo "✓ KVM module loaded"
    else
        echo "✗ KVM module not loaded"
    fi
    
    # Check for nested virtualization
    if cat /sys/module/kvm_intel/parameters/nested 2>/dev/null | grep -q 1; then
        echo "✓ Nested virtualization enabled (Intel)"
    elif cat /sys/module/kvm_amd/parameters/nested 2>/dev/null | grep -q 1; then
        echo "✓ Nested virtualization enabled (AMD)"
    else
        echo "ℹ Nested virtualization not enabled (not critical)"
    fi
    
    # Check for guest halt polling
    if cat /sys/module/kvm/parameters/halt_poll_ns 2>/dev/null | grep -qv 0; then
        echo "✓ Guest halt polling enabled (FPS improvement)"
    else
        echo "ℹ Guest halt polling disabled (enable for FPS boost)"
    fi
    
    echo ""
    echo "To enable guest halt polling:"
    echo "  echo 50000 | sudo tee /sys/module/kvm/parameters/halt_poll_ns"
    echo ""

[group('Virtualization')]
@enable-guest-halt-polling:
    #!/usr/bin/bash
    echo "Enabling guest halt polling for FPS improvement..."
    echo "This can improve Windows VM FPS by 4-71% according to Intel research"
    echo ""
    
    if echo "50000" | sudo tee /sys/module/kvm/parameters/halt_poll_ns > /dev/null; then
        echo "✓ Guest halt polling enabled (50000 ns poll period)"
        echo ""
        echo "Current KVM polling settings:"
        cat /sys/module/kvm/parameters/halt_poll_ns
    else
        echo "✗ Failed to enable - requires sudo"
    fi
    echo ""
    echo "To make permanent, add to /etc/modprobe.d/kvm-optimization.conf:"
    echo "  options kvm halt_poll_ns=50000"
    echo ""

[group('Virtualization')]
@list-vms:
    #!/usr/bin/bash
    echo "Registered virtual machines:"
    virsh list --all
    echo ""
