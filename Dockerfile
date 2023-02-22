# syntax=docker/dockerfile:1

FROM alpine:3 AS download-base
ARG RENPY_VERSION

# Download different sdk files depending on architecture
FROM download-base AS download-amd64
RUN wget -q https://www.renpy.org/dl/${RENPY_VERSION}/renpy-${RENPY_VERSION}-sdk.tar.bz2 \
    && tar -xjf renpy-${RENPY_VERSION}-sdk.tar.bz2 --no-same-owner \
    && mv renpy-${RENPY_VERSION}-sdk renpy-sdk

FROM download-base AS download-arm64
RUN wget -q https://www.renpy.org/dl/${RENPY_VERSION}/renpy-${RENPY_VERSION}-sdkarm.tar.bz2 \
    && tar -xjf renpy-${RENPY_VERSION}-sdkarm.tar.bz2 --no-same-owner \
    && mv renpy-${RENPY_VERSION}-sdkarm renpy-sdk

FROM download-${TARGETARCH} AS download


FROM debian:11.6-slim
ARG RENPY_VERSION

ENV RENPY_VERSION=${RENPY_VERSION}

RUN apt-get update && apt-get install --no-install-recommends -y \
        # Necessary for renpy to start.
        libgl1 \
        # For running a game through X11.
        libxi6 \
        # May only libxi6 is need, so it's currently not installed.
        # freeglut3 \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -r renpy && useradd -r -g renpy renpy \
    && mkdir /renpy \
    && chown renpy:renpy /renpy


WORKDIR /renpy

COPY --from=download --chmod=777 /renpy-sdk .

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
