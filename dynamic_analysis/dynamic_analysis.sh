#!/bin/bash

# Usage check
if [ $# -ne 1 ]; then
    echo "Usage: $0 <malware-binary>"
    exit 1
fi

MALWARE_BIN="$1"
IMAGE_DIR="../qemu_docker_images"
WORK_DIR="$PWD"
MALWARE_NAME=$(basename "$MALWARE_BIN")

# Determine architecture
ARCH_OUTPUT=$(file "$MALWARE_BIN")
ARCH_DESC=$(echo "$ARCH_OUTPUT" | sed 's/^[^:]*: //')
echo "[*] Detected binary type: $ARCH_DESC"

if echo "$ARCH_DESC" | grep -qi "ARM"; then
    IMAGE_NAME="arm-qemu-1.0-uclibc.tar.gz"
elif echo "$ARCH_DESC" | grep -qi "MIPSEL"; then
    IMAGE_NAME="mipsel-qemu-1.0-uclibc.tar.gz"
elif echo "$ARCH_DESC" | grep -qi "MIPS"; then
    IMAGE_NAME="mips-qemu-1.0-uclibc.tar.gz"
elif echo "$ARCH_DESC" | grep -qi "SPARC"; then
    IMAGE_NAME="sparc-qemu-1.0-uclibc.tar.gz"
elif echo "$ARCH_DESC" | grep -qi "PowerPC"; then
    IMAGE_NAME="ppc-qemu-1.0-uclibc.tar.gz"
elif echo "$ARCH_DESC" | grep -qi "SuperH"; then
    IMAGE_NAME="sh4-qemu-1.0-uclibc.tar.gz"
else
    echo "[!] Unsupported architecture."
    exit 2
fi

echo "[*] Selected image: $IMAGE_NAME"

# Copy image
cp "$IMAGE_DIR/$IMAGE_NAME" "$WORK_DIR/" || { echo "[!] Failed to copy image."; exit 3; }

# Decompress image
gunzip -f "$IMAGE_NAME" || { echo "[!] Failed to decompress image."; exit 4; }

# Load Docker image
IMAGE_TAR="${IMAGE_NAME%.gz}"
docker load -i "$IMAGE_TAR" || { echo "[!] Failed to load Docker image."; exit 5; }

# Get image ID or name
IMAGE_ID=$(docker load -i "$IMAGE_TAR" | awk '/Loaded image: / {print $3}')

# Test container run
docker run --rm -it "$IMAGE_ID" -h || { echo "[!] Docker image test run failed."; exit 6; }

# Create malware directory if not exists
mkdir -p "$WORK_DIR/malware"
cp "$MALWARE_BIN" "$WORK_DIR/malware/"

# Run dynamic analysis
docker run -it --rm -v "$WORK_DIR/malware:/br2/bins" --privileged "$IMAGE_ID" -i "/br2/bins/$MALWARE_BIN" -r abc.exe -t 60

echo "[*] Dynamic analysis completed."
