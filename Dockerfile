FROM onlyoffice/documentserver:latest

# Включаем JWT и задаем параметры из Railway env
ENV JWT_ENABLED=true
ENV JWT_SECRET=7d586366a6a34827afc14f418e239df8
ENV JWT_HEADER=AuthorizationJwt
ENV JWT_IN_BODY=true

# Включаем CORS и разрешаем встраивание CRM-домена
ENV NGINX_CORS_ALLOW_ORIGIN=https://94793cf8-09ca-497a-a7f3-a913759231d7.lovableproject.com
ENV WOPI_ENABLED=true

# Скрипт: фиксим JWT + создаем CORS-конфиг + запускаем supervisord
RUN echo '#!/bin/bash\n\
sleep 5\n\
CONFIG=/etc/onlyoffice/documentserver/default.json\n\
if [ -f $CONFIG ]; then\n\
  sed -i "s/\"enable\": *false/\"enable\": true/g" $CONFIG\n\
  sed -i "s/\"secret\": *\"[^\"]*\"/\"secret\": \"${JWT_SECRET}\"/g" $CONFIG\n\
  echo \"✅ JWT config applied:\"\n\
  grep -A3 \"jwt\" $CONFIG\n\
fi\n\
# Добавляем CORS конфиг для CRM\n\
mkdir -p /etc/onlyoffice/documentserver/nginx/includes\n\
echo \"add_header Access-Control-Allow-Origin \\\"${NGINX_CORS_ALLOW_ORIGIN}\\\" always;\" > /etc/onlyoffice/documentserver/nginx/includes/custom-cors.conf\n\
echo \"add_header Access-Control-Allow-Methods \\\"GET, POST, OPTIONS\\\" always;\" >> /etc/onlyoffice/documentserver/nginx/includes/custom-cors.conf\n\
echo \"add_header Access-Control-Allow-Headers \\\"Authorization, Content-Type, Origin, Accept, X-Requested-With\\\" always;\" >> /etc/onlyoffice/documentserver/nginx/includes/custom-cors.conf\n\
echo \"add_header X-Frame-Options \\\"ALLOW-FROM ${NGINX_CORS_ALLOW_ORIGIN}\\\";\" >> /etc/onlyoffice/documentserver/nginx/includes/custom-cors.conf\n\
echo \"add_header Content-Security-Policy \\\"frame-ancestors ${NGINX_CORS_ALLOW_ORIGIN} *;\\\" always;\" >> /etc/onlyoffice/documentserver/nginx/includes/custom-cors.conf\n\
sed -i \"/include includes\\/http-common.conf;/a include includes\\/custom-cors.conf;\" /etc/onlyoffice/documentserver/nginx/ds.conf\n\
exec supervisord -c /etc/supervisor/supervisord.conf\n\
' > /run-and-fix.sh && chmod +x /run-and-fix.sh

CMD ["/bin/bash", "/run-and-fix.sh"]
