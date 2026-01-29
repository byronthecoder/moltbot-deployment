FROM alpine:latest

RUN apk add --no-cache bash curl jq

WORKDIR /app

COPY telegram-poller.sh /app/telegram-poller.sh
RUN chmod +x /app/telegram-poller.sh

CMD ["/app/telegram-poller.sh"]
