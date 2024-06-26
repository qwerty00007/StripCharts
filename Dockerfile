FROM alpine:3 as app
ENV TZ="Asia/Shanghai"

RUN apk add --no-cache curl git jq tzdata \
&& rm -rf /etc/localtime && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN 
COPY --chmod=0755 ./stripper.sh /strip/stripper.sh
COPY --chmod=0755 ./stripper.sh /etc/periodic/daily/strip

CMD ["sh", "-c", "/strip/stripper.sh && crond -f -l 2"]
