#!/usr/bin/env bash
set -e

VHOST_DIR="/var/lib/apache-vhosts"
CERT_DIR="/var/lib/ssl"

# Helper function to purge project-specific SSL certificate files if present
remove_ssl_certs() {
    local project_name="$1"
    local crt_file="${CERT_DIR}/${project_name}.crt"
    local key_file="${CERT_DIR}/${project_name}.key"

    if [ -f "$crt_file" ] || [ -f "$key_file" ]; then
        echo "🔑 Removing dedicated SSL certificates for ${project_name}..."
        rm -f "$crt_file" "$key_file"
    fi
}

# ====================================================================
# FEATURE: BULK WIPE DEPLOYMENT ENGINE
# ====================================================================
if [[ "$1" == "--all" ]]; then
    echo "========================================================="
    echo "🚨 INITIATING BULK UNLINK FOR ALL VIRTUAL HOSTS (*.test)"
    echo "========================================================="

    if [ ! -d "$VHOST_DIR" ] || [ -z "$(ls -A "$VHOST_DIR" 2>/dev/null)" ]; then
        echo " 💡 Configuration directory is already clean. Nothing to prune."
        echo "========================================================="
        exit 0
    fi

    echo "🗑️ Wiping all virtual host profile configurations and SSL certs:"
    for conf in "$VHOST_DIR"/*.conf; do
        [ -e "$conf" ] || continue
        filename=$(basename "$conf")
        project_name="${filename%.conf}"
        domain=$(grep -i "ServerName" "$conf" | head -n1 | awk '{print $2}' | tr -d '"\r\n')

        echo "   -> Removing: ${domain}"
        rm -f "$conf"
        remove_ssl_certs "$project_name"
    done

    echo "🔄 Reloading Apache HTTPD daemon configuration..."
    sudo systemctl reload httpd

    echo "🚀 Success! All virtual hosts and dedicated SSL certs have been unlinked."
    echo "========================================================="
    exit 0
fi

# ====================================================================
# INTERACTIVE FEATURE: SELECT PROJECT FROM REGISTERED LIST
# ====================================================================
# Convert current working directory name to lowercase for matching
RAW_PROJECT_NAME=$(basename "$PWD")
PROJECT_NAME=$(echo "$RAW_PROJECT_NAME" | tr '[:upper:]' '[:lower:]')
CONF_FILE="$VHOST_DIR/${PROJECT_NAME}.conf"

# If invoked without arguments AND current directory has no active linked config file
if [[ $# -eq 0 ]] && [ ! -f "$CONF_FILE" ]; then
    echo "========================================================="
    echo "🌐 ACTIVE VIRTUAL HOST LINKS (*.test)"
    echo "========================================================="

    if [ ! -d "$VHOST_DIR" ] || [ -z "$(ls -A "$VHOST_DIR" 2>/dev/null)" ]; then
        echo " 💡 No project domains linked yet."
        echo "========================================================="
        exit 0
    fi

    # Collect available .conf files into an array
    confs=("$VHOST_DIR"/*.conf)

    echo "Select a virtual host to unlink:"
    echo ""

    i=1
    for conf in "${confs[@]}"; do
        [ -e "$conf" ] || continue
        domain=$(grep -i "ServerName" "$conf" | head -n1 | awk '{print $2}' | tr -d '"\r\n')
        doc_root=$(grep -i "DocumentRoot" "$conf" | head -n1 | awk '{print $2}' | tr -d '"\r\n')

        printf "  [\033[1;36m%2d\033[0m] %-28s -> %s\n" "$i" "$domain" "$doc_root"
        i=$((i+1))
    done

    echo ""
    echo "  [\033[1;31m q\033[0m] Cancel / Exit"
    echo "========================================================="

    read -p "Enter your selection: " choice

    if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
        echo "❌ Operation cancelled."
        exit 0
    fi

    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -lt "$i" ]; then
        selected_conf="${confs[$((choice-1))]}"
        filename=$(basename "$selected_conf")
        PROJECT_NAME="${filename%.conf}"
        DOMAIN="${PROJECT_NAME}.test"
        CONF_FILE="$selected_conf"
    else
        echo "❌ Invalid selection."
        exit 1
    fi
else
    # Use current working directory project name
    DOMAIN="${PROJECT_NAME}.test"
fi

# ====================================================================
# SINGLE VIRTUAL HOST UNLINK EXECUTION
# ====================================================================
echo "🔍 Probing virtual host configuration..."

if [ -f "$CONF_FILE" ]; then
    echo "🗑️ Removing Apache virtual host entry file for ${DOMAIN}..."
    sudo rm -f "$CONF_FILE"

    remove_ssl_certs "$PROJECT_NAME"

    echo "🔄 Reloading Apache HTTPD daemon configuration..."
    sudo systemctl reload httpd

    echo "🚀 Success! ${DOMAIN} and associated SSL certificates have been unlinked."
else
    echo "💡 No active virtual host configuration mapped for ${DOMAIN} in ${VHOST_DIR}."
fi
