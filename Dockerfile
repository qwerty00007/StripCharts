FROM alpine:3 as app

RUN apk add --no-cache curl git unzip jq bash cron

RUN touch /var/log/cron.log

COPY --chmod=0755 ./stripper.sh /strip/stripper.sh
COPY crontab /etc/cron.d/cjob
RUN chmod 0644 /etc/cron.d/cjob

CMD ["bash", "-c", "/strip/stripper.sh && cron -f"]
