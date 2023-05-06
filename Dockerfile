FROM alpine:3.17

# BUPT is in China.
# Uncomment the following line if you need mirrors.
# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

# Install bash and curl.
RUN apk --no-cache add bash curl

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY bupt-net-login /bupt-net-login

ENTRYPOINT [ "/docker-entrypoint.sh" ]
