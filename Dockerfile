ARG GODOT_VERSION=4.6.3

FROM barichello/godot-ci:${GODOT_VERSION}

RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 libfontconfig1 \
    && rm -rf /var/lib/apt/lists/*

COPY build.sh /usr/local/bin/build.sh
RUN chmod +x /usr/local/bin/build.sh

WORKDIR /project

ENTRYPOINT ["/usr/local/bin/build.sh"]
