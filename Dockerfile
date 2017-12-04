FROM klokantech/tileserver-gl:v2.3.0

RUN set -x \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get update \
    && apt-get install -y jq curl

WORKDIR /config

ARG STYLES_ASSETS=https://github.com/Neo-Type/openmaptiles-styles/releases/download/v0.1.0/v0.1.0.tar.gz
RUN set -x \
    && curl -sL "${STYLES_ASSETS}" | tar -zxv

COPY config/config.json /config/config.json
COPY config/jq.sh /config/jq.sh
RUN /config/jq.sh

ENTRYPOINT []
CMD ["/usr/src/app/run.sh", "--config=/config/config.json"]
