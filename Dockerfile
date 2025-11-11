FROM onlyoffice/documentserver:latest

ENV JWT_ENABLED=true
ENV JWT_SECRET=7d586366a6a34827afc14f418e239df8
ENV JWT_HEADER=AuthorizationJwt
ENV JWT_IN_BODY=true

EXPOSE 8000
CMD ["/usr/bin/documentserver"]
