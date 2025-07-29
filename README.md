# 🔒 Fail2Ban Manager Script (NGINX + 404 Focused)

An interactive Bash script to install, configure, and manage **Fail2Ban** on Debian/Ubuntu systems — with built-in protection against repeated **404 errors** via **NGINX access logs**.

---

## 🚀 Features

- 📦 One-click Fail2Ban installation & setup
- 🔐 Protects NGINX servers from 404-based scans
- 👁 View currently banned IPs
- ➕ Manually ban IPs
- ➖ Unban IPs
- 🔄 Restart / stop Fail2Ban service
- 🧹 Full uninstall with config cleanup
- 🛡️ Set custom thresholds during install or later:
  - Max retry attempts
  - Find time (seconds)
  - Ban time (seconds)

---

## ⚙️ Installation

```bash
git clone https://github.com/habibi-dev/fail2ban-manager-nginx-404.git
cd fail2ban-manager
chmod +x fail2ban-manager.sh
./fail2ban-manager.sh
```

---

## 🛠 Custom Configuration

When installing or updating thresholds, you'll be prompted to define:

- **Max Retry Attempts** (e.g. 5)
- **Find Time** in seconds (e.g. 60)
- **Ban Time** in seconds (e.g. 3600)

These values will be written to `/etc/fail2ban/jail.local` and applied to the jail `nginx-404`.

---

## 📋 Requirements

- Debian or Ubuntu
- NGINX with access logs enabled (`/var/log/nginx/access.log`)
- Root privileges

---

## 💡 Menu Options

```
1) Install & configure Fail2Ban
2) Show banned IPs
3) Manually ban an IP
4) Unban an IP
5) Show Fail2Ban status
6) Stop Fail2Ban
7) Restart Fail2Ban
8) Remove Fail2Ban
9) Update thresholds
10) Exit
```

---

## 📝 License

MIT © 2025 [Habibi-Dev]
