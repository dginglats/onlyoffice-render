FROM onlyoffice/documentserver:latest

# Включаем JWT и задаем параметры из Railway env
ENV JWT_ENABLED=true
ENV JWT_SECRET=7d586366a6a34827afc14f418e239df8
ENV JWT_HEADER=AuthorizationJwt
ENV JWT_IN_BODY=true

# Включаем CORS и разрешаем встраивание CRM-домена
ENV NGINX_CORS_ALLOW_ORIGIN=https://94793cf8-09ca-497a-a7f3-a913759231d7.lovableproject.com
ENV WOPI_ENABLED=true

# Скрипт: фиксим JWT и запускаем supervisord
RUN echo '#!/bin/bash\n\
sleep 5\n\
CONFIG=/etc/onlyoffice/documentserver/default.json\n\
if [ -f $CONFIG ]; then\n\
  sed -i "s/\"enable\": *false/\"enable\": true/g" $CONFIG\n\
  sed -i "s/\"secret\": *\"[^\"]*\"/\"secret\": \"${JWT_SECRET}\"/g" $CONFIG\n\
  echo \"✅ JWT config applied:\"\n\
  grep -A3 \"jwt\" $CONFIG\n\
fi\n\
exec supervisord -c /etc/supervisor/supervisord.conf\n\
' > /run-and-fix.sh && chmod +x /run-and-fix.sh

# --- Enable CORS and iframe embedding for CRM domain ---
RUN mkdir -p /etc/onlyoffice/documentserver/nginx/includes && \
echo '\
add_header Access-Control-Allow-Origin "https://94793cf8-09ca-497a-a7f3-a913759231d7.lovableproject.com" always;\n\
add_header Access-Control-Allow-Methods "GET, POST, OPTIONS" always;\n\
add_header Access-Control-Allow-Headers "Authorization, Content-Type, Origin, Accept, X-Requested-With" always;\n\
add_header X-Frame-Options "ALLOW-FROM https://94793cf8-09ca-497a-a7f3-a913759231d7.lovableproject.com";\n\
add_header Content-Security-Policy "frame-ancestors https://94793cf8-09ca-497a-a7f3-a913759231d7.lovableproject.com *;" always;\
' > /etc/onlyoffice/documentserver/nginx/includes/custom-cors.conf && \
sed -i '/include includes\/ds-common.conf;/a include includes\/custom-cors.conf;' /etc/onlyoffice/documentserver/nginx/ds.conf

CMD ["/bin/bash", "/run-and-fix.sh"]
