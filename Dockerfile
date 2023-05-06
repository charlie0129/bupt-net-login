FROM alpine:3.17

# BUPT is in China. We need mirrors!
# Install bash and curl.
RUN sed -i \
    's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' \
    /etc/apk/repositories && \
    apk --no-cache add bash curl

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY bupt-net-login /bupt-net-login

ENTRYPOINT [ "/docker-entrypoint.sh" ]
