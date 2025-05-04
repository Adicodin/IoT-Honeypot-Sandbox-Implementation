#!/bin/bash

# Check if sample is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <malware_sample>"
  exit 1
fi

SAMPLE="$1"
REPORT="${SAMPLE}_static_report.json"
SHA256=$(sha256sum "$SAMPLE" | awk '{print $1}')
FILE_TYPE=$(file "$SAMPLE")

# Check for UPX packer
UPX_STATUS="Not packed"
if strings "$SAMPLE" | grep -q "UPX executable packer"; then
  if upx -t "$SAMPLE" > /dev/null 2>&1; then
    echo "🔍 UPX packed binary detected. Unpacking..."
    if upx -d "$SAMPLE" > /dev/null 2>&1; then
      UPX_STATUS="Unpacked with UPX"
      FILE_TYPE=$(file "$SAMPLE")  # Refresh file type after unpacking
    else
      UPX_STATUS="Packed (unpacking failed)"
    fi
  fi
fi

# Strings Summary
STRINGS_SUMMARY=$(strings "$SAMPLE" | grep -Ei 'http|wget|curl|nc|ftp|bash|sh' | sed 's/"/\\"/g' | sed 's/^/"/;s/$/",/' | tr -d '\n')

# Network Indicators
NETWORK_IPS=$(strings "$SAMPLE" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | sort | uniq | sed 's/"/\\"/g' | sed 's/^/"/;s/$/",/' | tr -d '\n')
NETWORK_URLS=$(strings "$SAMPLE" | grep -Eo 'https?://[^ ]+' | sort | uniq | sed 's/"/\\"/g' | sed 's/^/"/;s/$/",/' | tr -d '\n')

# ELF Metadata if ELF
if echo "$FILE_TYPE" | grep -q "ELF"; then
  ELF_HEADER=$(readelf -h "$SAMPLE" | sed 's/"/\\"/g' | sed 's/^/"/;s/$/",/' | tr -d '\n')
  ELF_SECTIONS=$(readelf -S "$SAMPLE" | sed 's/"/\\"/g' | sed 's/^/"/;s/$/",/' | tr -d '\n')
  ELF_LIBRARIES=$(readelf -d "$SAMPLE" | grep 'Shared library' | sed 's/"/\\"/g' | sed 's/^/"/;s/$/",/' | tr -d '\n')
else
  ELF_HEADER=""
  ELF_SECTIONS=""
  ELF_LIBRARIES=""
fi

# Build JSON manually
echo "{" > "$REPORT"
echo "  \"sample_name\": \"$SAMPLE\"," >> "$REPORT"
echo "  \"sha256\": \"$SHA256\"," >> "$REPORT"
echo "  \"file_details\": \"$FILE_TYPE\"," >> "$REPORT"
echo "  \"upx_status\": \"$UPX_STATUS\"," >> "$REPORT"

# Strings Summary
echo "  \"strings_summary\": [" >> "$REPORT"
echo "    ${STRINGS_SUMMARY%,}" >> "$REPORT"
echo "  ]," >> "$REPORT"

# ELF Metadata
echo "  \"elf_metadata\": {" >> "$REPORT"
echo "    \"header\": [${ELF_HEADER%,}]," >> "$REPORT"
echo "    \"sections\": [${ELF_SECTIONS%,}]," >> "$REPORT"
echo "    \"linked_libraries\": [${ELF_LIBRARIES%,}]" >> "$REPORT"
echo "  }," >> "$REPORT"

# Network Indicators
echo "  \"network_indicators\": {" >> "$REPORT"
echo "    \"ips\": [${NETWORK_IPS%,}]," >> "$REPORT"
echo "    \"urls\": [${NETWORK_URLS%,}]" >> "$REPORT"
echo "  }" >> "$REPORT"

echo "}" >> "$REPORT"

echo "✔️ Static analysis complete. Report saved to: $REPORT"
