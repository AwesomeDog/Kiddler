FROM ghcr.io/mccutchen/go-httpbin AS builder

FROM alpine:latest AS builder2
RUN apk add --no-cache pandoc
ADD ./README.md /tmp/README.md
RUN pandoc /tmp/README.md -f markdown -t html -s -o /tmp/index.html


FROM openresty/openresty:1.27.1.2-4-jammy

LABEL maintainer="AwesomeDog"
LABEL description="Web and HTTP Debugging and Troubleshooting in Kubernetes Made Simple"

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root

# Common network tools
RUN apt-get update && apt-get install -y \
    # Basic network tools
    iputils-ping \
    net-tools \
    iproute2 \
    # Network diagnostic tools
    traceroute \
    mtr \
    tcpdump \
    ethtool \
    # DNS tools
    dnsutils \
    # Connection testing tools
    curl \
    wget \
    telnet \
    # Bandwidth testing tools
    iperf3 \
    # Other net tools
    whois \
    netcat-openbsd \
    socat \
    nmap \
    # Other tools
    tmux \
    htop \
    vim \
    supervisor \
    # Clean up cache to reduce image size
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /bin/go-httpbin /app/
RUN chmod +x /app/go-httpbin

RUN mkdir -p /var/log/supervisor
COPY ./config/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN wget -O /usr/local/bin/ttyd "https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64" \
    && chmod +x /usr/local/bin/ttyd

RUN rm -rf /etc/nginx/conf.d/*
COPY ./config/nginx/ /etc/nginx/conf.d/

COPY --from=builder2 /tmp/index.html /usr/local/openresty/nginx/html/index.html

EXPOSE 80 443 8001

CMD ["/usr/bin/supervisord"]
