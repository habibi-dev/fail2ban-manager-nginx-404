#!/bin/bash

# Enhanced Fail2Ban for Nginx 404 Protection Manager
# Author: Enhanced version with auto-installation and optimization

# Configuration
CONFIG_DIR="/etc/fail2ban"
JAIL_LOCAL="$CONFIG_DIR/jail.local"
FILTER_DIR="$CONFIG_DIR/filter.d"
FILTER_FILE="$FILTER_DIR/nginx-404.conf"
NGINX_LOG="/var/log/nginx/access.log"

# Colors for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Icons
CHECK="✅"
CROSS="❌"
QUESTION="❓"
CLOCK="⏱️"
BAN="⛔"
INFO="ℹ️"
GEAR="⚙️"

# Utility functions
print_colored() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_success() {
    print_colored "$GREEN" "$CHECK $1"
}

print_error() {
    print_colored "$RED" "$CROSS $1"
}

print_warning() {
    print_colored "$YELLOW" "⚠️  $1"
}

print_info() {
    print_colored "$CYAN" "$INFO $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

# Check if fail2ban is installed
is_fail2ban_installed() {
    command -v fail2ban-client &> /dev/null
}

# Check if fail2ban service is running
is_fail2ban_running() {
    systemctl is-active --quiet fail2ban
}

# Auto-install fail2ban if not present
auto_install_fail2ban() {
    if ! is_fail2ban_installed; then
        print_info "Fail2Ban not found. Installing automatically..."
        
        # Update package list
        print_info "Updating package list..."
        apt update -qq
        
        # Install fail2ban
        print_info "Installing Fail2Ban..."
        if apt install -y fail2ban &> /dev/null; then
            print_success "Fail2Ban installed successfully"
        else
            print_error "Failed to install Fail2Ban"
            exit 1
        fi
        
        # Create directories
        mkdir -p "$CONFIG_DIR" "$FILTER_DIR"
        
        # Create filter configuration
        create_filter_config
        
        # Initial configuration
        configure_jail "auto"
        
        # Enable and start service
        systemctl enable fail2ban &> /dev/null
        systemctl start fail2ban &> /dev/null
        
        print_success "Fail2Ban configured and started successfully"
        echo
    fi
}

# Create filter configuration
create_filter_config() {
    cat > "$FILTER_FILE" << 'EOF'
[Definition]
failregex = ^<HOST> -.*"(GET|POST|HEAD|PUT|DELETE|PATCH).*(404|" 404)"
ignoreregex = 
EOF
}

# Configure jail with default or custom values
configure_jail() {
    local mode=${1:-"interactive"}
    local maxretry findtime bantime
    
    if [[ "$mode" == "auto" ]]; then
        # Default values for auto-installation
        maxretry=5
        findtime=300
        bantime=3600
        print_info "Using default values: maxretry=$maxretry, findtime=$findtime, bantime=$bantime"
    else
        # Interactive configuration
        echo
        print_colored "$PURPLE" "$GEAR Jail Configuration"
        echo "────────────────────────────"
        
        read -p "$(print_colored "$YELLOW" "$QUESTION Max retry attempts") [default: 5]: " maxretry
        maxretry=${maxretry:-5}
        
        read -p "$(print_colored "$YELLOW" "$CLOCK Find time in seconds") [default: 300]: " findtime
        findtime=${findtime:-300}
        
        read -p "$(print_colored "$YELLOW" "$BAN Ban time in seconds") [default: 3600]: " bantime
        bantime=${bantime:-3600}
    fi
    
    # Validate inputs
    if ! [[ "$maxretry" =~ ^[0-9]+$ ]] || ! [[ "$findtime" =~ ^[0-9]+$ ]] || ! [[ "$bantime" =~ ^[0-9]+$ ]]; then
        print_error "Invalid input. Please enter numeric values only."
        return 1
    fi
    
    # Check if nginx log exists
    if [[ ! -f "$NGINX_LOG" ]]; then
        print_warning "Nginx log file not found at $NGINX_LOG"
        read -p "Enter custom nginx log path: " NGINX_LOG
        if [[ ! -f "$NGINX_LOG" ]]; then
            print_error "Log file still not found. Please check nginx installation."
            return 1
        fi
    fi
    
    # Create jail configuration
    cat > "$JAIL_LOCAL" << EOF
[DEFAULT]
# Ban hosts for one hour
bantime = $bantime

# Override /etc/fail2ban/jail.d/00-firewalld.conf
banaction = iptables-multiport

[nginx-404]
enabled = true
port = http,https
filter = nginx-404
logpath = $NGINX_LOG
maxretry = $maxretry
findtime = $findtime
bantime = $bantime
EOF
    
    # Restart fail2ban to apply changes
    if systemctl restart fail2ban &> /dev/null; then
        print_success "Configuration applied successfully"
        print_info "Settings: Max attempts: $maxretry, Find time: ${findtime}s, Ban time: ${bantime}s"
    else
        print_error "Failed to restart Fail2Ban service"
        return 1
    fi
}

# Show dynamic menu based on installation status
show_menu() {
    clear
    print_colored "$BLUE" "╔════════════════════════════════════╗"
    print_colored "$BLUE" "║     Fail2Ban Nginx 404 Manager    ║"
    print_colored "$BLUE" "╚════════════════════════════════════╝"
    
    # Show status
    if is_fail2ban_installed; then
        if is_fail2ban_running; then
            print_colored "$GREEN" "Status: $CHECK Running"
        else
            print_colored "$RED" "Status: $CROSS Stopped"
        fi
    else
        print_colored "$YELLOW" "Status: Not Installed"
    fi
    
    echo
    echo "Options:"
    echo "────────"
    
    if is_fail2ban_installed; then
        echo "1. 📊 Show banned IPs"
        echo "2. 🔓 Unban IP address"
        echo "3. 🔒 Ban IP manually"
        echo "4. ⚙️  Reconfigure jail settings"
        echo "5. 📋 Show jail status"
        echo "6. 🔄 Restart Fail2Ban"
        if is_fail2ban_running; then
            echo "7. ⏹️  Stop Fail2Ban"
        else
            echo "7. ▶️  Start Fail2Ban"
        fi
        echo "8. 🗑️  Remove Fail2Ban completely"
    fi
    
    echo "0. 🚪 Exit"
    echo
}

# Show banned IPs with better formatting
show_banned() {
    print_info "Current banned IPs for nginx-404 jail:"
    echo "─────────────────────────────────────────"
    
    if ! fail2ban-client status nginx-404 2>/dev/null; then
        print_error "nginx-404 jail is not active or fail2ban is not running"
        return 1
    fi
}

# Unban IP with validation
unban_ip() {
    echo
    read -p "$(print_colored "$YELLOW" "Enter IP address to unban"): " ip
    
    # Basic IP validation
    if [[ ! "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        print_error "Invalid IP address format"
        return 1
    fi
    
    if fail2ban-client set nginx-404 unbanip "$ip" &> /dev/null; then
        print_success "$ip has been unbanned"
    else
        print_error "Failed to unban $ip (may not be banned or jail inactive)"
    fi
}

# Ban IP manually with validation
ban_ip() {
    echo
    read -p "$(print_colored "$YELLOW" "Enter IP address to ban"): " ip
    
    # Basic IP validation
    if [[ ! "$ip" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        print_error "Invalid IP address format"
        return 1
    fi
    
    if fail2ban-client set nginx-404 banip "$ip" &> /dev/null; then
        print_success "$ip has been banned"
    else
        print_error "Failed to ban $ip"
    fi
}

# Show jail status
show_jail_status() {
    print_info "Fail2Ban service status:"
    echo "────────────────────────────"
    systemctl status fail2ban --no-pager -l
    echo
    print_info "Available jails:"
    echo "───────────────"
    fail2ban-client status 2>/dev/null || print_error "Fail2Ban is not running"
}

# Control fail2ban service
control_service() {
    local action=$1
    
    if systemctl "$action" fail2ban &> /dev/null; then
        case "$action" in
            "start") print_success "Fail2Ban started" ;;
            "stop") print_success "Fail2Ban stopped" ;;
            "restart") print_success "Fail2Ban restarted" ;;
        esac
    else
        print_error "Failed to $action Fail2Ban service"
    fi
}

# Remove fail2ban completely
remove_fail2ban() {
    echo
    print_warning "This will completely remove Fail2Ban and all configurations!"
    read -p "Are you sure? (y/N): " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Stopping Fail2Ban service..."
        systemctl stop fail2ban &> /dev/null
        
        print_info "Removing Fail2Ban package..."
        apt remove -y fail2ban &> /dev/null
        
        print_info "Removing configuration files..."
        rm -rf "$CONFIG_DIR"
        
        print_success "Fail2Ban has been completely removed"
    else
        print_info "Operation cancelled"
    fi
}

# Wait for user input
wait_for_input() {
    echo
    read -p "Press Enter to continue..."
}

# Main function
main() {
    check_root
    auto_install_fail2ban
    
    while true; do
        show_menu
        read -p "$(print_colored "$CYAN" "Select an option"): " choice
        
        case "$choice" in
            1) show_banned; wait_for_input ;;
            2) unban_ip; wait_for_input ;;
            3) ban_ip; wait_for_input ;;
            4) configure_jail; wait_for_input ;;
            5) show_jail_status; wait_for_input ;;
            6) control_service "restart"; wait_for_input ;;
            7) 
                if is_fail2ban_running; then
                    control_service "stop"
                else
                    control_service "start"
                fi
                wait_for_input
                ;;
            8) remove_fail2ban; wait_for_input ;;
            0) 
                print_success "Goodbye!"
                exit 0
                ;;
            *) 
                print_error "Invalid option! Please try again."
                sleep 1
                ;;
        esac
    done
}

# Run main function
main "$@"
