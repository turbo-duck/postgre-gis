FROM postgis/postgis:latest
ENV POSTGRES_DB=space
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=123123
EXPOSE 5432
COPY init-db.sh /docker-entrypoint-initdb.d/
