FROM onlyoffice/documentserver:latest

# --- JWT настройки ---
ENV JWT_ENABLED=true
ENV JWT_SECRET=7d586366a6a34827afc14f418e239df8
ENV JWT_HEADER=
ENV JWT_IN_BODY=true

# --- CORS и разрешение встраивания CRM ---
# Можно указать несколько доменов через пробел
ENV NGINX_CORS_ALLOW_ORIGIN="https://94793cf8-09ca-497a-a7f3-a913759231d7.lovableproject.com https://solardrive.site"
ENV WOPI_ENABLED=true

# --- Скрипт старта с фиксом JWT, CORS и root path (sdkjs) ---
RUN echo '#!/bin/bash\n\
sleep 5\n\
CONFIG=/etc/onlyoffice/documentserver/default.json\n\
NGINX_CONF=/etc/onlyoffice/documentserver/nginx/ds.conf\n\
CUSTOM_CORS=/etc/onlyoffice/documentserver/nginx/includes/custom-cors.conf\n\
\n\
# --- Fix JWT ---\n\
if [ -f $CONFIG ]; then\n\
  sed -i \"s/\\\"enable\\\": *false/\\\"enable\\\": true/g\" $CONFIG\n\
  sed -i \"s/\\\"secret\\\": *\\\"[^\\\"]*\\\"/\\\"secret\\\": \\\"${JWT_SECRET}\\\"/g\" $CONFIG\n\
  echo \"✅ JWT config applied\"\n\
  grep -A3 \"jwt\" $CONFIG\n\
fi\n\
\n\
# --- Fix Nginx root path (for 9.1+) ---\n\
if grep -q \"web-apps\" $NGINX_CONF; then\n\
  sed -i \"s/web-apps/sdkjs/g\" $NGINX_CONF\n\
  echo \"✅ Updated nginx root path to /sdkjs\"\n\
fi\n\
\n\
# --- Add CORS dynamically ---\n\
mkdir -p /etc/onlyoffice/documentserver/nginx/includes\n\
cat > $CUSTOM_CORS <<EOL\n\
add_header Access-Control-Allow-Origin \"${NGINX_CORS_ALLOW_ORIGIN}\" always;\n\
add_header Access-Control-Allow-Methods \"GET, POST, OPTIONS\" always;\n\
add_header Access-Control-Allow-Headers \"Authorization, Content-Type, Origin, Accept, X-Requested-With\" always;\n\
add_header X-Frame-Options \"ALLOW-FROM ${NGINX_CORS_ALLOW_ORIGIN}\";\n\
add_header Content-Security-Policy \"frame-ancestors ${NGINX_CORS_ALLOW_ORIGIN} *;\" always;\n\
EOL\n\
if ! grep -q custom-cors.conf $NGINX_CONF; then\n\
  sed -i \"/include includes\\/ds-common.conf;/a include includes\\/custom-cors.conf;\" $NGINX_CONF\n\
fi\n\
\n\
echo \"✅ CORS rules added for: ${NGINX_CORS_ALLOW_ORIGIN}\"\n\
exec supervisord -c /etc/supervisor/supervisord.conf\n\
' > /run-and-fix.sh && chmod +x /run-and-fix.sh

CMD ["/bin/bash", "/run-and-fix.sh"]
