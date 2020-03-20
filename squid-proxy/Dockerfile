FROM alpine

ENV TZ 'Asia/Shanghai'

RUN set -x \
    && echo $TZ > /etc/timezone \
    # Install Squid.
    && apk add --no-cache squid tini 

#EXPOSE 3128

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod a+x /usr/bin/entrypoint.sh

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["sh","-c","/usr/bin/entrypoint.sh"]
