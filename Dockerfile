FROM onlyoffice/documentserver:latest

# Включаем JWT и задаем параметры из Railway env
ENV JWT_ENABLED=true
ENV JWT_SECRET=7d586366a6a34827afc14f418e239df8
ENV JWT_HEADER=AuthorizationJwt
ENV JWT_IN_BODY=true

# Принудительно записываем JWT-секрет в конфиг при старте контейнера
RUN echo '#!/bin/bash\n\
sleep 5\n\
CONFIG=/etc/onlyoffice/documentserver/default.json\n\
if [ -f $CONFIG ]; then\n\
  sed -i "s/\"enable\": *false/\"enable\": true/g" $CONFIG\n\
  sed -i "s/\"secret\": *\"[^\"]*\"/\"secret\": \"${JWT_SECRET}\"/g" $CONFIG\n\
  echo "✅ JWT config applied:"\n\
  grep -A3 \"jwt\" $CONFIG\n\
fi\n\
exec supervisord -c /etc/supervisor/supervisord.conf\n\
' > /run-and-fix.sh && chmod +x /run-and-fix.sh

CMD ["/bin/bash", "/run-and-fix.sh"]
