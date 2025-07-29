# 🔒 Enhanced Fail2Ban Manager Script (NGINX + 404 Protection)

An intelligent, interactive Bash script to **automatically install**, configure, and manage **Fail2Ban** on Debian/Ubuntu systems — featuring advanced protection against **404-based attacks** via **NGINX access logs** with beautiful colored interface.

---

## ✨ Key Features

### 🤖 **Smart Auto-Installation**
- 🔄 **Automatic Detection**: Checks if Fail2Ban is installed on first run
- 📦 **One-Click Setup**: Auto-installs and configures everything if not present
- ⚙️ **Intelligent Defaults**: Uses optimized default settings for immediate protection
- 🎯 **Dynamic Menu**: Menu adapts based on installation and service status

### 🛡️ **Advanced Protection**
- 🚫 **404 Attack Prevention**: Protects against directory scanning and brute force attempts
- 🔍 **Multi-Method Support**: Covers GET, POST, HEAD, PUT, DELETE, PATCH requests
- 📊 **Real-time Monitoring**: Live tracking of banned IPs and jail status
- 🎛️ **Flexible Configuration**: Customizable thresholds and timing settings

### 🎨 **Beautiful Interface**
- 🌈 **Colored Output**: Easy-to-read colored messages and status indicators
- 🔤 **Unicode Icons**: Modern icons for better visual experience
- 📋 **Smart Validation**: Input validation for IP addresses and numeric values
- 🔄 **Live Status**: Real-time service and jail status display

---

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/habibi-dev/fail2ban-manager-nginx-404.git

# Navigate to directory
cd fail2ban-manager-nginx-404

# Make executable
chmod +x fail2ban-manager.sh

# Run as root (will auto-install if needed)
sudo ./fail2ban-manager.sh
```

> **Note**: The script will automatically detect if Fail2Ban is missing and install it with optimal default settings!

---

## 🛠 Configuration Options

### Default Settings (Auto-Installation)
- **Max Retry Attempts**: `5` failed attempts
- **Find Time**: `300` seconds (5 minutes)
- **Ban Time**: `3600` seconds (1 hour)
- **Target Log**: `/var/log/nginx/access.log`

### Custom Configuration
You can modify these settings anytime through the interactive menu:
- 🔢 **Max Retry**: Number of 404 attempts before ban
- ⏱️ **Find Time**: Time window to count attempts  
- 🚫 **Ban Duration**: How long IPs stay banned
- 📁 **Log Path**: Custom NGINX log file location

All settings are saved to `/etc/fail2ban/jail.local` for persistence.

---

## 📋 System Requirements

- **OS**: Debian 9+ or Ubuntu 18.04+
- **Web Server**: NGINX with access logging enabled
- **Privileges**: Root access (sudo)
- **Dependencies**: Automatically installed (fail2ban, iptables)

---

## 🎛️ Interactive Menu

The script features a dynamic menu that changes based on your system state:

### When Fail2Ban is Installed:
```
╔════════════════════════════════════╗
║     Fail2Ban Nginx 404 Manager    ║
╚════════════════════════════════════╝

Status: ✅ Running

Options:
────────
1. 📊 Show banned IPs
2. 🔓 Unban IP address  
3. 🔒 Ban IP manually
4. ⚙️  Reconfigure jail settings
5. 📋 Show jail status
6. 🔄 Restart Fail2Ban
7. ⏹️  Stop Fail2Ban
8. 🗑️  Remove Fail2Ban completely
0. 🚪 Exit
```

---

## 🔧 Advanced Features

### 🎯 **Smart IP Validation**
- Validates IP address format before ban/unban operations
- Prevents invalid entries and system errors

### 📊 **Comprehensive Status Display**
- Real-time service status monitoring
- Detailed jail statistics and banned IP lists
- System integration status

### 🔄 **Service Management**
- Start/stop/restart Fail2Ban service
- Automatic service enabling on installation
- Clean removal with configuration cleanup

### 🛡️ **Security Enhancements**
- Enhanced regex patterns for better attack detection
- Support for multiple HTTP methods
- Customizable log file paths
- Persistent configuration across reboots

---

## 📁 File Structure

```
/etc/fail2ban/
├── jail.local              # Main jail configuration
└── filter.d/
    └── nginx-404.conf      # Custom 404 filter rules
```

---

## 🔍 Filter Configuration

The script creates an optimized filter at `/etc/fail2ban/filter.d/nginx-404.conf`:

```ini
[Definition]
failregex = ^<HOST> -.*"(GET|POST|HEAD|PUT|DELETE|PATCH).*(404|" 404)"
ignoreregex = 
```

This pattern catches various HTTP methods returning 404 errors, providing comprehensive protection.

---

## 🚨 Troubleshooting

### Common Issues:

**NGINX Log Not Found**
- Script will prompt for custom log path
- Ensure NGINX access logging is enabled

**Permission Issues**
- Always run with `sudo` or as root user
- Check file permissions in `/etc/fail2ban/`

**Service Won't Start**
- Check jail configuration syntax
- Verify log file exists and is readable

---

## 🔄 Updates & Maintenance

The script is designed for minimal maintenance:
- Configurations persist across system reboots
- Service automatically starts with system
- Easy reconfiguration through interactive menu
- Complete removal option available

---

## 📈 Performance Impact

- **Minimal CPU Usage**: Efficient log parsing
- **Low Memory Footprint**: Lightweight monitoring
- **Fast Response**: Real-time IP blocking
- **System Integration**: Uses native iptables rules

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

---

## 📄 License

MIT © 2025 [Habibi-Dev]

---

## 🔗 Related Links

- [Fail2Ban Official Documentation](https://www.fail2ban.org/)
- [NGINX Logging Configuration](https://nginx.org/en/docs/http/ngx_http_log_module.html)
- [iptables Firewall Rules](https://netfilter.org/projects/iptables/)

---

**Made with ❤️ for server security**
