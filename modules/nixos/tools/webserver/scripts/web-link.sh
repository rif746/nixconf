#!/usr/bin/env bash
set -e

VHOST_DIR="/var/lib/apache-vhosts"
CERT_DIR="/var/lib/ssl"
CA_DIR="/var/lib/ssl/ca"

# Convert Project name into lowercase
RAW_PROJECT_NAME=$(basename "$PWD")
PROJECT_NAME=$(echo "$RAW_PROJECT_NAME" | tr '[:upper:]' '[:lower:]')

DOMAIN="${PROJECT_NAME}.test"
CONF_FILE="$VHOST_DIR/${PROJECT_NAME}.conf"

DOMAIN_CRT="${CERT_DIR}/${PROJECT_NAME}.crt"
DOMAIN_KEY="${CERT_DIR}/${PROJECT_NAME}.key"

if [ -d "$PWD/public" ]; then
    DOC_ROOT="$PWD/public"
else
    DOC_ROOT="$PWD"
fi

PHP_VERSION="${1:-8.5}"

if [ "$PHP_VERSION" == "8.3" ]; then
    SOCKET_PATH="/run/phpfpm/php83.sock"
elif [ "$PHP_VERSION" == "8.5" ]; then
    SOCKET_PATH="/run/phpfpm/php85.sock"
else
    echo "❌ Unknown PHP version selection: $PHP_VERSION."
    exit 1
fi

# ====================================================================
# GENERATE SSL CERTIFICATE AS REGULAR USER
# ====================================================================
export CAROOT="$CA_DIR"

echo "🔑 Generating dedicated SSL certificate for ${DOMAIN}..."
mkcert -cert-file "$DOMAIN_CRT" -key-file "$DOMAIN_KEY" "$DOMAIN" "*.$DOMAIN"

# Pastikan file sertifikat dan key dapat dibaca oleh Apache (wwwrun)
chmod 644 "$DOMAIN_CRT"
chmod 640 "$DOMAIN_KEY"
sudo chown :wwwrun "$DOMAIN_CRT" "$DOMAIN_KEY" 2>/dev/null || true
# ====================================================================

echo "🔒 Configuring parent directory traversal routes..."
CURRENT_DIR="$PWD"
while [ "$CURRENT_DIR" != "/" ]; do
    sudo chmod o+x "$CURRENT_DIR"
    CURRENT_DIR=$(dirname "$CURRENT_DIR")
done
chmod -R g+rX "$PWD"

echo "🔗 Binding ${DOMAIN} (HTTPS) to ${DOC_ROOT} using PHP ${PHP_VERSION}..."

cat <<EOF > "$CONF_FILE"
# HTTP -> HTTPS Redirect VHost
<VirtualHost *:80>
    ServerName ${DOMAIN}
    ServerAlias *.${DOMAIN}

    RewriteEngine On
    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
</VirtualHost>

# Dedicated HTTPS VHost
<VirtualHost *:443>
    ServerName ${DOMAIN}
    ServerAlias *.${DOMAIN}
    DocumentRoot "${DOC_ROOT}"

    SSLEngine on
    SSLCertificateFile ${DOMAIN_CRT}
    SSLCertificateKeyFile ${DOMAIN_KEY}

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
if sudo systemctl reload httpd; then
    echo "🚀 Success! Your site is live at https://${DOMAIN}"
else
    echo "❌ Apache reload failed! Cleaning invalid VirtualHost..."
    rm -f "$CONF_FILE" "$DOMAIN_CRT" "$DOMAIN_KEY"
    sudo systemctl reload httpd || true
    exit 1
fi
