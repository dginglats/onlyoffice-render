FROM onlyoffice/documentserver:latest

ENV JWT_ENABLED=true
ENV JWT_SECRET=7d586366a6a34827afc14f418e239df8
ENV JWT_HEADER=AuthorizationJwt
ENV JWT_IN_BODY=true

EXPOSE 8000

# Запускаем DocumentServer после правки default.json
CMD service postgresql start && \
    service rabbitmq-server start && \
    service nginx start && \
    sleep 10 && \
    sed -i 's/"enable": false/"enable": true/g' /etc/onlyoffice/documentserver/default.json && \
    sed -i 's/"secret": ""/"secret": "7d586366a6a34827afc14f418e239df8"/g' /etc/onlyoffice/documentserver/default.json && \
    echo "==== JWT CONFIGURATION APPLIED ====" && \
    grep -A3 '"jwt"' /etc/onlyoffice/documentserver/default.json && \
    /usr/bin/documentserver
