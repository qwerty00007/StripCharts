FROM alpine:3 as app

RUN apk add --no-cache curl git jq

COPY --chmod=0755 ./stripper.sh /strip/stripper.sh
COPY --chmod=0755 ./stripper.sh /etc/periodic/daily/strip

CMD ["sh", "-c", "/strip/stripper.sh && crond -f -l 2"]
