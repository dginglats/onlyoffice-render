FROM onlyoffice/documentserver:latest

# --- JWT настройки ---
ENV JWT_ENABLED=true
ENV JWT_SECRET=7d586366a6a34827afc14f418e239df8
ENV JWT_HEADER=
ENV JWT_IN_BODY=true

# --- CORS и разрешённые домены ---
ENV NGINX_CORS_ALLOW_ORIGIN="https://94793cf8-09ca-497a-a7f3-a913759231d7.lovableproject.com https://solardrive.site"
ENV WOPI_ENABLED=true

# --- Копируем entrypoint в контейнер ---
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
