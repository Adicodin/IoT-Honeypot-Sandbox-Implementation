# IoT-Honeypot-Sandbox-Implementation
A complete toolkit for capturing, analyzing, and visualizing IoT malware using TPOT, static/dynamic analysis and web-based dashboards.

## Features

* 📥 **Malware Capture Dashboard**: Visual interface to track and manage captured IoT malware from TPOT based IoT specific honeypots automatically in real time.
* 🧪 **Static Analysis**: Bash + Python scripts for ELF analysis, UPX detection/unpacking, string extraction, and IP/URL detection.
* 🐚 **Dynamic Analysis**: Architecture-specific QEMU Docker environments to execute malware and collect system calls and network PCAPs with the help of https://github.com/alrawi/badthings-tools/tree/master/dynamic_analysis.
* 📊 **Dashboards**: Lightweight HTML+JS dashboards to visualize both static and dynamic analysis reports.

## Tech Stack

* Bash, Python, JavaScript, HTML/CSS
* QEMU, Docker (multi-arch images from `badthings-tools`)
* Tools: `binwalk`, `upx`, `readelf`, `7z`, `unzip`, `strace`, `tcpdump`

## Folder Structure

```
malware_capture_dashboard/   # Malware listing & download panel
static_analysis/             # Scripts + HTML dashboard
dynamic_analysis/            # Docker-QEMU workflows + HTML dashboard
```

## Getting Started

### Malware Capture Dashboard
To identify and access the details of the captured malware from TPOT automatically and live, follow these steps:
1. In the machine where TPOT is deployed, clone the repo and `cd` to `malware_capture_dashboard/` directory
2. Follow the README.md present in that directory

### Automated Static Analysis
Setup an Ubuntu 22.04 LTS Server Image with 
- Memory: 4 GB RAM
- CPU: 2 cores
- Storage: 40 GB
- Network Configuration: Host-Only Adapter for full network isolation and safe handling of malicious binaries and NAT Adapter temporarily to fetch external dependencies.

The following tools and libraries to be installed in the VM to support static analysis: 
- python3
- binwalk (firmware and binary inspection)
- p7zip-full (extraction of .zip malware samples)
- unzip (basic extraction utility)
- upx (packer detection and binary unpacking),

1. `cd` to static_analysis
3. Run `iot_static_analysis_json_upx.sh` on samples.
4. Use `iot_static_analysis.html` to view static reports. Upload the json results to this dashboard.

### Automated Dynamic Analysis
1. `cd dynamic_analysis`
2. Follow its README.md

## Credits

* Based on methods from: [adumbrati0n’s Mirai/Echobot Case Study](https://adumbrati0n.medium.com/malware-analysis-iot-case-study-mirai-echobot-0e0ec4e255d8)
* Docker-QEMU images from: [`alrawi/badthings-tools`](https://github.com/alrawi/badthings-tools)
* TPOT from: [TPOTCE](https://github.com/telekom-security/tpotce?tab=readme-ov-file#system-requirements)
