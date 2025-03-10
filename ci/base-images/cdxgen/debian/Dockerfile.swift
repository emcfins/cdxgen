FROM ghcr.io/cyclonedx/debian-swift:master

LABEL maintainer="CycloneDX" \
      org.opencontainers.image.authors="Team AppThreat <cloud@appthreat.com>" \
      org.opencontainers.image.source="https://github.com/CycloneDX/cdxgen" \
      org.opencontainers.image.url="https://github.com/CycloneDX/cdxgen" \
      org.opencontainers.image.version="rolling" \
      org.opencontainers.image.vendor="CycloneDX" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.title="cdxgen" \
      org.opencontainers.image.description="Rolling image with cdxgen SBOM generator for swift apps" \
      org.opencontainers.docker.cmd="docker run --rm -v /tmp:/tmp -p 9090:9090 -v $(pwd):/app:rw -t ghcr.io/cyclonedx/cdxgen-debian-swift:v11 -r /app --server"

ENV CDXGEN_IN_CONTAINER=true \
    NODE_COMPILE_CACHE="/opt/cdxgen-node-cache" \
    PYTHONPATH=/opt/pypi
ENV PATH=${PATH}:/usr/local/bin:/opt/pypi/bin:/opt/cdxgen/node_modules/.bin:

COPY . /opt/cdxgen

RUN cd /opt/cdxgen && corepack enable && corepack pnpm install --config.strict-dep-builds=true --prod --package-import-method copy && corepack pnpm cache delete \
    && mkdir -p /opt/cdxgen-node-cache \
    && node /opt/cdxgen/bin/cdxgen.js --help \
    && pip install --upgrade --no-cache-dir blint atom-tools --target /opt/pypi \
    && chmod a-w -R /opt
WORKDIR /app
ENTRYPOINT ["node", "/opt/cdxgen/bin/cdxgen.js"]
