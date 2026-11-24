#!/usr/bin/env bash
set -e

VHOST_DIR="/var/lib/apache-vhosts"
CERT_DIR="/var/lib/ssl"
CA_DIR="/var/lib/ssl/ca"

# ====================================================================
# HELPERS
# ====================================================================
show_help() {
    cat <<EOF
Usage: $(basename "$0") <command> [arguments] [options]

Commands:
  link [domain] [--use <8.3|8.5>]   Link current directory to a local HTTPS domain (default PHP: 8.5)
  unlink [domain] [--all]           Unlink current directory, specific domain, interactive list, or all
  links                             List all active VirtualHost links and their PHP versions
  help                              Show this help message

Examples:
  $(basename "$0") link                        # Link <folder>.test with PHP 8.5
  $(basename "$0") link --use 8.3              # Link <folder>.test with PHP 8.3
  $(basename "$0") link kampus.test --use 8.3  # Link kampus.test with PHP 8.3
  $(basename "$0") unlink                      # Unlink <folder>.test or pick from interactive list
  $(basename "$0") unlink kampus.test          # Unlink specific domain
  $(basename "$0") unlink --all                # Purge all VirtualHosts and SSL certs
  $(basename "$0") links                       # Show all active links
EOF
}

normalize_domain() {
    local input="$1"
    if [[ -n "$input" ]]; then
        input=$(echo "$input" | tr '[:upper:]' '[:lower:]')
        if [[ "$input" == *.* ]]; then
            echo "$input"
        else
            echo "${input}.test"
        fi
    else
        local raw_name
        raw_name=$(basename "$PWD")
        echo "$(echo "$raw_name" | tr '[:upper:]' '[:lower:]').test"
    fi
}

domain_to_slug() {
    local domain="$1"
    local slug="${domain%.test}"
    echo "${slug//[^a-z0-9.-]/_}"
}

remove_ssl_certs() {
    local slug="$1"
    local crt_file="${CERT_DIR}/${slug}.crt"
    local key_file="${CERT_DIR}/${slug}.key"

    if [[ -f "$crt_file" || -f "$key_file" ]]; then
        echo "🔑 Removing dedicated SSL certificates for ${slug}..."
        sudo rm -f "$crt_file" "$key_file"
    fi
}

reload_apache() {
    echo "🔄 Reloading Apache HTTPD configuration..."
    sudo systemctl reload httpd
}

# ====================================================================
# COMMAND: link
# ====================================================================
cmd_link() {
    local custom_domain=""
    local php_version="8.5"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --use)
                if [[ -z "$2" || "$2" == -* ]]; then
                    echo "❌ Option --use requires a PHP version (e.g., --use 8.3)."
                    exit 1
                fi
                php_version="$2"
                shift 2
                ;;
            --use=*)
                php_version="${1#*=}"
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                echo "❌ Unknown option for 'link': $1"
                exit 1
                ;;
            *)
                if [[ -n "$custom_domain" ]]; then
                    echo "❌ Multiple domains provided: '$custom_domain' and '$1'."
                    exit 1
                fi
                custom_domain="$1"
                shift
                ;;
        esac
    done

    local socket_path
    case "$php_version" in
        8.3) socket_path="/run/phpfpm/php83.sock" ;;
        8.5) socket_path="/run/phpfpm/php85.sock" ;;
        *)
            echo "❌ Unknown PHP version selection: $php_version (supported: 8.3, 8.5)."
            exit 1
            ;;
    esac

    local domain slug conf_file domain_crt domain_key doc_root
    domain=$(normalize_domain "$custom_domain")
    slug=$(domain_to_slug "$domain")

    conf_file="${VHOST_DIR}/${slug}.conf"
    domain_crt="${CERT_DIR}/${slug}.crt"
    domain_key="${CERT_DIR}/${slug}.key"

    if [[ -d "$PWD/public" ]]; then
        doc_root="$PWD/public"
    else
        doc_root="$PWD"
    fi

    export CAROOT="$CA_DIR"
    echo "🔑 Generating dedicated SSL certificate for ${domain}..."
    mkcert -cert-file "$domain_crt" -key-file "$domain_key" "$domain" "*.$domain"
    chmod 644 "$domain_crt"
    chmod 600 "$domain_key"

    echo "🔗 Binding ${domain} (HTTPS) to ${doc_root} using PHP ${php_version}..."
    cat <<EOF | sudo tee "$conf_file" > /dev/null
# HTTP -> HTTPS Redirect VHost
<VirtualHost *:80>
    ServerName ${domain}
    ServerAlias *.${domain}

    RewriteEngine On
    RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
</VirtualHost>

# Dedicated HTTPS VHost
<VirtualHost *:443>
    ServerName ${domain}
    ServerAlias *.${domain}
    DocumentRoot "${doc_root}"

    SSLEngine on
    SSLCertificateFile ${domain_crt}
    SSLCertificateKeyFile ${domain_key}

    <Directory "${doc_root}">
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
        DirectoryIndex index.php index.html
    </Directory>

    <FilesMatch \.php$>
        SetHandler "proxy:unix:${socket_path}|fcgi://localhost"
    </FilesMatch>
</VirtualHost>
EOF

    if reload_apache; then
        echo "🚀 Success! Your site is live at https://${domain}"
    else
        echo "❌ Apache reload failed! Cleaning invalid VirtualHost..."
        sudo rm -f "$conf_file" "$domain_crt" "$domain_key"
        sudo systemctl reload httpd || true
        exit 1
    fi
}

# ====================================================================
# COMMAND: unlink
# ====================================================================
cmd_unlink() {
    local custom_domain=""
    local unlink_all=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --all)
                unlink_all=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                echo "❌ Unknown option for 'unlink': $1"
                exit 1
                ;;
            *)
                if [[ -n "$custom_domain" ]]; then
                    echo "❌ Multiple domains provided: '$custom_domain' and '$1'."
                    exit 1
                fi
                custom_domain="$1"
                shift
                ;;
        esac
    done

    # Bulk wipe mode (--all)
    if [[ "$unlink_all" == true ]]; then
        echo "========================================================="
        echo "🚨 INITIATING BULK UNLINK FOR ALL VIRTUAL HOSTS"
        echo "========================================================="

        if [[ ! -d "$VHOST_DIR" ]] || [[ -z "$(ls -A "$VHOST_DIR" 2>/dev/null)" ]]; then
            echo " 💡 Configuration directory is already clean. Nothing to prune."
            echo "========================================================="
            exit 0
        fi

        echo "🗑️  Wiping all virtual host profile configurations and SSL certs:"
        for conf in "$VHOST_DIR"/*.conf; do
            [[ -e "$conf" ]] || continue
            local filename slug domain
            filename=$(basename "$conf")
            slug="${filename%.conf}"
            domain=$(grep -i "ServerName" "$conf" | head -n1 | awk '{print $2}' | tr -d '"\r\n')

            echo "   -> Removing: ${domain:-$slug}"
            sudo rm -f "$conf"
            remove_ssl_certs "$slug"
        done

        reload_apache
        echo "🚀 Success! All virtual hosts and dedicated SSL certs have been unlinked."
        echo "========================================================="
        exit 0
    fi

    local domain slug conf_file
    domain=$(normalize_domain "$custom_domain")
    slug=$(domain_to_slug "$domain")
    conf_file="${VHOST_DIR}/${slug}.conf"

    # Interactive selection if no domain argument was passed and current dir has no matching vhost
    if [[ -z "$custom_domain" && ! -f "$conf_file" ]]; then
        echo "========================================================="
        echo "🌐 ACTIVE VIRTUAL HOST LINKS"
        echo "========================================================="

        if [[ ! -d "$VHOST_DIR" ]] || [[ -z "$(ls -A "$VHOST_DIR" 2>/dev/null)" ]]; then
            echo " 💡 No project domains linked yet."
            echo "========================================================="
            exit 0
        fi

        local confs=("$VHOST_DIR"/*.conf)
        echo "Select a virtual host to unlink:"
        echo ""

        local i=1
        for conf in "${confs[@]}"; do
            [[ -e "$conf" ]] || continue
            local item_domain item_root
            item_domain=$(grep -i "ServerName" "$conf" | head -n1 | awk '{print $2}' | tr -d '"\r\n')
            item_root=$(grep -i "DocumentRoot" "$conf" | head -n1 | awk '{print $2}' | tr -d '"\r\n')

            printf "  [\033[1;36m%2d\033[0m] %-28s -> %s\n" "$i" "$item_domain" "$item_root"
            i=$((i + 1))
        done

        echo ""
        printf "  [\033[1;31m q\033[0m] Cancel / Exit"
        echo "========================================================="

        read -rp "Enter your selection: " choice
        if [[ "$choice" == "q" || "$choice" == "Q" ]]; then
            echo "❌ Operation cancelled."
            exit 0
        fi

        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 && "$choice" -lt "$i" ]]; then
            conf_file="${confs[$((choice - 1))]}"
            local filename
            filename=$(basename "$conf_file")
            slug="${filename%.conf}"
            domain=$(grep -i "ServerName" "$conf_file" | head -n1 | awk '{print $2}' | tr -d '"\r\n')
            domain="${domain:-${slug}.test}"
        else
            echo "❌ Invalid selection."
            exit 1
        fi
    fi

    echo "🔍 Probing virtual host configuration..."
    if [[ -f "$conf_file" ]]; then
        echo "🗑️  Removing Apache virtual host entry file for ${domain}..."
        sudo rm -f "$conf_file"
        remove_ssl_certs "$slug"
        reload_apache
        echo "🚀 Success! ${domain} and associated SSL certificates have been unlinked."
    else
        echo "💡 No active virtual host configuration mapped for ${domain} in ${VHOST_DIR}."
    fi
}

# ====================================================================
# COMMAND: links
# ====================================================================
cmd_links() {
    echo "================================================================================"
    echo "🌐 ACTIVE VIRTUAL HOST LINKS"
    echo "================================================================================"

    if [[ ! -d "$VHOST_DIR" ]] || [[ -z "$(ls -A "$VHOST_DIR" 2>/dev/null)" ]]; then
        echo " 💡 No project domains linked yet."
        echo "================================================================================"
        exit 0
    fi

    printf "  %-30s %-8s %s\n" "DOMAIN" "PHP" "DOCUMENT ROOT"
    echo "--------------------------------------------------------------------------------"
    for conf in "$VHOST_DIR"/*.conf; do
        [[ -e "$conf" ]] || continue
        local domain doc_root php_ver
        domain=$(grep -i "ServerName" "$conf" | head -n1 | awk '{print $2}' | tr -d '"\r\n')
        doc_root=$(grep -i "DocumentRoot" "$conf" | head -n1 | awk '{print $2}' | tr -d '"\r\n')

        if grep -q "php83.sock" "$conf"; then
            php_ver="8.3"
        elif grep -q "php85.sock" "$conf"; then
            php_ver="8.5"
        else
            php_ver="unknown"
        fi

        printf "  %-30s %-8s %s\n" "https://${domain}" "$php_ver" "$doc_root"
    done
    echo "================================================================================"
}

# ====================================================================
# ENTRYPOINT DISPATCHER
# ====================================================================
SUBCOMMAND="${1:-}"
case "$SUBCOMMAND" in
    link)
        shift
        cmd_link "$@"
        ;;
    unlink)
        shift
        cmd_unlink "$@"
        ;;
    links)
        shift
        cmd_links "$@"
        ;;
    ""|-h|--help|help)
        show_help
        ;;
    *)
        echo "❌ Unknown command: $SUBCOMMAND"
        echo "Run '$(basename "$0") --help' for usage."
        exit 1
        ;;
esac
