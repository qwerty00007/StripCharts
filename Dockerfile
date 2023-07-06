FROM debian:12 as app

RUN apt update && apt install curl git unzip jq bash -y

COPY --chmod=0755 ./stripper.sh /strip/stripper.sh
COPY --chmod=0755 ./stripper.sh /etc/periodic/daily/strip

CMD ["bash", "-c", "/strip/stripper.sh && crond -f -l 2"]
