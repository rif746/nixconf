#!/usr/bin/env bash
set -e

VHOST_DIR="/var/lib/apache-vhosts"

# ====================================================================
# NEW FEATURE: BULK WIPE DEPLOYMENT ENGINE
# ====================================================================
if [[ "$1" == "--all" ]]; then
    echo "========================================================="
    echo "🚨 BULK UNLINK INITIATED (*.test)"
    echo "========================================================="

    if [ ! -d "$VHOST_DIR" ] || [ -z "$(ls -A "$VHOST_DIR" 2>/dev/null)" ]; then
        echo " 💡 Your configuration directory is already clean. Nothing to prune."
        echo "========================================================="
        exit 0
    fi

    # Read and output all targets to confirm structural clean up actions
    echo "🗑️ Wiping the following configuration profiles out of existence:"
    for conf in "$VHOST_DIR"/*.conf; do
        [ -e "$conf" ] || continue
        domain=$(grep -i "ServerName" "$conf" | awk '{print $2}' | tr -d '"\r\n')
        echo "   -> Removing: $domain"
        rm -f "$conf"
    done

    echo "🔄 Refreshing web server infrastructure daemons..."
    sudo systemctl reload httpd

    echo "🚀 Success! All virtual host registrations have been securely wiped clean."
    echo "========================================================="
    exit 0
fi
# ====================================================================

# Standard variables setup for localized single directory unlinking
PROJECT_NAME=$(basename "$PWD")
DOMAIN="${PROJECT_NAME}.test"
CONF_FILE="$VHOST_DIR/${PROJECT_NAME}.conf"

echo "🔍 Probing for local virtual host links..."

if [ -f "$CONF_FILE" ]; then
    echo "🗑️ Removing Apache virtual host entry file for ${DOMAIN}..."
    sudo rm -f "$CONF_FILE"

    echo "🔄 Reloading Apache configuration..."
    sudo systemctl reload httpd

    echo "🚀 Success! ${DOMAIN} has been safely unlinked."
else
    echo "💡 No active virtual host configuration mapped for ${DOMAIN} inside ${VHOST_DIR}."
fi
