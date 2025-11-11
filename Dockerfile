FROM onlyoffice/documentserver:latest

ENV JWT_ENABLED=true
ENV JWT_SECRET=7d586366a6a34827afc14f418e239df8
ENV JWT_HEADER=AuthorizationJwt
ENV JWT_IN_BODY=true

RUN sed -i 's/"inbox":{"enable":false}/"inbox":{"enable":true}/' /etc/onlyoffice/documentserver/default.json \
    && sed -i 's/"outbox":{"enable":false}/"outbox":{"enable":true}/' /etc/onlyoffice/documentserver/default.json \
    && sed -i 's/"browser":{"enable":false}/"browser":{"enable":true}/' /etc/onlyoffice/documentserver/default.json \
    && sed -i 's/"secret":""/"secret":"7d586366a6a34827afc14f418e239df8"/' /etc/onlyoffice/documentserver/default.json

EXPOSE 8000
CMD ["/usr/bin/documentserver"]
