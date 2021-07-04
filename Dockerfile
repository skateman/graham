FROM alpine:3.13
MAINTAINER "Dávid Halász"
LABEL description="RF 433MHz to MQTT transmitter for Home Assistant"

ENV MQTT_HOST localhost
ENV MQTT_PORT 1888
ENV MQTT_USER ""
ENV MQTT_PASS ""

RUN apk add --no-cache librtlsdr gcc make cmake curl jq musl-dev libusb-dev librtlsdr-dev && \
    cd /tmp && \
    curl -L $(curl -s https://api.github.com/repos/merbanan/rtl_433/releases/latest | jq '.tarball_url' | tr -d \") | tar xz && \
    cd merbanan-rtl_433* && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    make install && \
    apk del gcc make cmake curl jq musl-dev libusb-dev librtlsdr-dev && \
    cd / && \
    rm -rf /tmp/merbanan-rtl_433* && \
    mkdir -p /etc/rtl_433 && \
    touch /etc/rtl_433/config

CMD /usr/local/bin/rtl_433 -F mqtt://${MQTT_HOST}:${MQTT_PORT},user=${MQTT_USER},pass=${MQTT_PASS},retain=0,devices=rtl_433[/model] -c /etc/rtl_433/config
