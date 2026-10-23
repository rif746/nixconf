#!/usr/bin/env bash
set -e

VHOST_DIR="/var/lib/apache-vhosts"

# ====================================================================
# NEW FEATURE: LIST ACTIVE DOMAINS MODULE
# ====================================================================
if [[ "$1" == "--list" ]] || [[ "$1" == "-l" ]]; then
    echo "========================================================="
    echo "🌐 ACTIVE VIRTUAL HOST LINKS (*.test)"
    echo "========================================================="

    if [ ! -d "$VHOST_DIR" ] || [ -z "$(ls -A "$VHOST_DIR" 2>/dev/null)" ]; then
        echo " 💡 No project domains linked yet. Run 'web-link' inside a project."
        echo "========================================================="
        exit 0
    fi

    # Read each configuration file and scrape the ServerName and DocumentRoot properties
    for conf in "$VHOST_DIR"/*.conf; do
        [ -e "$conf" ] || continue

        # Scrape and trim strings
        domain=$(grep -i "ServerName" "$conf" | awk '{print $2}' | tr -d '"\r\n')
        doc_root=$(grep -i "DocumentRoot" "$conf" | awk '{print $2}' | tr -d '"\r\n')

        # Format the layout output
        printf "🔗 \033[1;34mhttp://%-24s\033[0m -> %s\n" "$domain" "$doc_root"
    done
    echo "========================================================="
    exit 0
fi
# ====================================================================

# Standard variables setup for standard binding usage
PROJECT_NAME=$(basename "$PWD")
DOMAIN="${PROJECT_NAME}.test"
CONF_FILE="$VHOST_DIR/${PROJECT_NAME}.conf"

if [ -d "$PWD/public" ]; then
    DOC_ROOT="$PWD/public"
else
    DOC_ROOT="$PWD"
fi

# Version Detection Selection Engine
PHP_VERSION="${1:-8.5}"

if [ "$PHP_VERSION" == "8.3" ]; then
    SOCKET_PATH="/run/phpfpm/php83.sock"
    echo "⚡ Using PHP 8.3 (Legacy Pool) handler mapping."
elif [ "$PHP_VERSION" == "8.5" ]; then
    SOCKET_PATH="/run/phpfpm/php85.sock"
    echo "🔥 Using PHP 8.5 (Latest Pool) handler mapping."
else
    echo "❌ Unknown version selection: $PHP_VERSION. Choose '8.3' or '8.5'."
    exit 1
fi

echo "🔒 Configuring parent directory traversal routes..."
CURRENT_DIR="$PWD"
while [ "$CURRENT_DIR" != "/" ]; do
    sudo chmod o+x "$CURRENT_DIR"
    CURRENT_DIR=$(dirname "$CURRENT_DIR")
done
chmod -R g+rX "$PWD"

echo "🔗 Binding ${DOMAIN} to ${DOC_ROOT} using PHP ${PHP_VERSION}..."

cat <<EOF > "$CONF_FILE"
<VirtualHost *:80>
    ServerName ${DOMAIN}
    ServerAlias *.${DOMAIN}
    DocumentRoot "${DOC_ROOT}"

    <Directory "${DOC_ROOT}">
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
        DirectoryIndex index.php index.html
    </Directory>

    <FilesMatch \.php$>
        SetHandler "proxy:unix:${SOCKET_PATH}|fcgi://localhost"
    </FilesMatch>
</VirtualHost>
EOF

echo "🔄 Reloading Apache configuration..."
sudo systemctl reload httpd

echo "🚀 Success! Your site is live at http://${DOMAIN}"
