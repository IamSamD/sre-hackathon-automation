FROM alpine:latest

WORKDIR /app

COPY ./build/automation-api .

RUN addgroup --system automation-api && \
    adduser --system --no-create-home automation-api

RUN chown -R automation-api:automation-api /app/automation-api && \
    chmod 750 /app/automation-api

USER automation-api

EXPOSE 8080

ENTRYPOINT [ "./automation-api" ]