FROM onlyoffice/documentserver:latest

ENV JWT_ENABLED=true
ENV JWT_SECRET=7d586366a6a34827afc14f418e239df8
ENV JWT_HEADER=AuthorizationJwt
ENV JWT_IN_BODY=true

# Добавляем скрипт для включения JWT после запуска DocumentServer
RUN echo '#!/bin/bash\n\
sleep 10\n\
sed -i "s/\"enable\": false/\"enable\": true/g" /etc/onlyoffice/documentserver/default.json\n\
sed -i "s/\"secret\": \"\"/\"secret\": \"7d586366a6a34827afc14f418e239df8\"/g" /etc/onlyoffice/documentserver/default.json\n\
echo "==== JWT configuration patched ===="\n\
grep -A3 \"jwt\" /etc/onlyoffice/documentserver/default.json\n\
exit 0' > /apply-jwt.sh && chmod +x /apply-jwt.sh

# Добавляем отдельный конфиг для supervisor (работает в этом образе)
RUN echo '[program:apply-jwt]\n\
command=/bin/bash /apply-jwt.sh\n\
autostart=true\n\
startsecs=0\n\
priority=1\n\
stdout_logfile=/dev/stdout\n\
stderr_logfile=/dev/stderr\n\
' > /etc/supervisor/conf.d/apply-jwt.conf

EXPOSE 8000
CMD service postgresql start && service rabbitmq-server start && service nginx start && /usr/bin/documentserver
