# syntax=docker/dockerfile:1

FROM alpine:3 AS download
ARG RENPY_VERSION

RUN wget -q https://www.renpy.org/dl/${RENPY_VERSION}/renpy-${RENPY_VERSION}-sdk.tar.bz2 \
    && tar -xjf renpy-${RENPY_VERSION}-sdk.tar.bz2 \
    && mv renpy-${RENPY_VERSION}-sdk renpy-sdk


FROM debian:11.6
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

WORKDIR /renpy

COPY --from=download /renpy-sdk .

ENTRYPOINT ["./renpy.sh"]
