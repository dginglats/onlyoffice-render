#!/bin/bash
set -e
echo "🔧 Starting OnlyOffice custom init..."

CONFIG=/etc/onlyoffice/documentserver/default.json
NGINX_CONF=/etc/onlyoffice/documentserver/nginx/ds.conf
CUSTOM_CORS=/etc/onlyoffice/documentserver/nginx/includes/custom-cors.conf

# --- JWT ---
if [ -f "$CONFIG" ]; then
  sed -i 's/"enable": *false/"enable": true/g' "$CONFIG"
  sed -i "s/\"secret\": *\"[^\"]*\"/\"secret\": \"${JWT_SECRET}\"/g" "$CONFIG"
  echo "✅ JWT config applied"
  grep -A3 "jwt" "$CONFIG" || true
fi

# --- Fix nginx root path ---
if grep -q "web-apps" "$NGINX_CONF"; then
  sed -i "s/web-apps/sdkjs/g" "$NGINX_CONF"
  echo "✅ Updated nginx root path to /sdkjs"
else
  echo "ℹ️ nginx path already correct"
fi

# --- CORS ---
mkdir -p /etc/onlyoffice/documentserver/nginx/includes
cat > "$CUSTOM_CORS" <<EOL
add_header Access-Control-Allow-Origin "${NGINX_CORS_ALLOW_ORIGIN}" always;
add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;
add_header Access-Control-Allow-Headers "Authorization, Content-Type, Origin, Accept, X-Requested-With" always;
add_header X-Frame-Options "ALLOW-FROM ${NGINX_CORS_ALLOW_ORIGIN}";
add_header Content-Security-Policy "frame-ancestors ${NGINX_CORS_ALLOW_ORIGIN} *;" always;
EOL

if ! grep -q custom-cors.conf "$NGINX_CONF"; then
  sed -i '/include includes\/ds-common.conf;/a include includes\/custom-cors.conf;' "$NGINX_CONF"
fi

echo "✅ CORS rules added for: ${NGINX_CORS_ALLOW_ORIGIN}"

# --- Fix legacy /web-apps path for OnlyOffice integrations ---
echo "✅ Adding /web-apps redirect for compatibility..."
cat <<'EOL' >> /etc/onlyoffice/documentserver/nginx/includes/ds-common.conf
# Redirect old OnlyOffice paths used by CRMs
location ~ ^/web-apps/(.*)$ {
    rewrite ^/web-apps/(.*)$ /sdkjs/$1 break;
    try_files /sdkjs/$1 =404;
}
EOL


echo "🚀 Starting DocumentServer supervisor..."
exec /app/ds/run-document-server.sh
