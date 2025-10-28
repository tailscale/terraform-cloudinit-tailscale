#!/bin/sh

# Ensure ethtool is installed
if ! command -v ethtool >/dev/null 2>&1; then
    echo "ethtool not found. Skipping network optimizations."
    exit 0
fi

# Get the current kernel version
current_version=$(uname -r | cut -d'-' -f1 | cut -d'.' -f1,2)

# Define the minimum required version
required_version="6.2"

# Detect the default network device. See https://tailscale.com/s/ethtool-config-udp-grow for more information.
get_default_netdev() {
    # Try ip route show first
    NETDEV=$(ip route show default | awk '/default/ {print $5}' | head -n1)
    
    # If ip route show didn't work, try using /sys/class/net
    if [ -z "$NETDEV" ]; then
        for dev in /sys/class/net/*; do
            if [ "$dev" != "/sys/class/net/lo" ]; then
                NETDEV=$(basename "$dev")
                break
            fi
        done
    fi
    
    # If we still don't have a network device, use a fallback
    if [ -z "$NETDEV" ]; then
        echo "eth0"  # Fallback to a common default
    else
        echo "$NETDEV"
    fi
}

# Compare versions
if [ "$(printf '%s\n' "$current_version" "$required_version" | sort -V | tail -n1)" = "$current_version" ]; then
    echo "Kernel version is 6.2 or later. Enabling optimizations..."
    NETDEV=$(get_default_netdev)
    if [ -n "$NETDEV" ]; then
        echo "Using network device: $NETDEV"
        sudo ethtool -K "$NETDEV" rx-udp-gro-forwarding on rx-gro-list off
    else
        echo "Error: Unable to determine network device. Exiting."
        exit 1
    fi
else
    echo "Kernel version is less than 6.2. Exiting."
    exit 0
fi
