# Ren'Py in Docker

[<img src="https://img.shields.io/badge/dockerhub-old6ix/renpy-important.svg?logo=docker">](https://hub.docker.com/r/old6ix/renpy/)

## Features

- Build distributions for [Ren'Py](https://www.renpy.org/) projects
- Launch projects through [X11](https://www.x.org/wiki/guide/concepts/)
- Support multi architectures: `amd64`, `arm64`
- Run as non-root user by setting `PUID` and `PGID`, like [linuxserver.io does](https://docs.linuxserver.io/general/understanding-puid-and-pgid/)

## Usage

All examples below are based on [Ren'Py 8.0.3](https://www.renpy.org/release/8.0.3).

### Quickstart

To build a PC distribution for the official example game, `The Question`, you can run a single command:

```bash
docker run --rm -it -v ${PWD}/out:/out \
  old6ix/renpy:8.0.3 launcher distribute ./the_question --dest /out --package pc
```

Then you will get the distribution in `out/` directory:

```bash
$ ls out/
the_question-7.0-pc.zip
```

### Build distributions for your own game

Technically, you can bind your project to nearly any directory you want, but I'd like to choose `/src`.

```bash
docker run --rm -it \
  -v /path/to/renpy/project:/src \
  -v /path/to/output:/out \
  old6ix/renpy:8.0.3 launcher distribute /src --dest /out
```

You should get distributions for different platform in `/path/to/output` directory.

### Launch a project 

Most of the operations in this section are for configuring [X11](https://www.x.org/wiki/guide/concepts/). Don't panic, it's easy even if you know little about it. Just follow the steps; If you're familiar with it, you can jump to the 3rd launching step.

#### 1. Set a displaying screen

*Note: If you prefer skipping this step, just open a terminal in your Linux desktop, which is likely to finish the setting automatically.*

Set `$DISPLAY` env to choose which screen you want the GUI to be shown on. For example:

```bash
export DISPLAY=:0.0
```

will make your game be displayed on the 1st screen of the 1st display (might your only screen). If you want to get a brief introduction about `$DISPLAY`, I believe [this discussion in Ask Ubuntu](https://askubuntu.com/questions/432255/what-is-the-display-environment-variable/) will help you a lot.

#### 2. Grant permission to the running user

Use `xhost` to allow the running user to make connections to the X server. Since we were running renpy as `root` so far, let's still use `root` as an example. Running as non-root user will be discussed in next section. 

```bash
xhost +local:root
```

This command will allow `root` user to display on screen `$DISPLAY`.

#### 3. Launch

To run `The Question` as a demo, execute this command:

```bash
docker run --rm -it \
  -e DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  old6ix/renpy:8.0.3 ./the_question
```

This window will be displayed on the screen you've set in the first step:

![Screenshot](https://user-images.githubusercontent.com/108944730/219942328-47a9566b-11c0-419f-bbc5-950849e2f7d2.png)

Or your own game:

```bash
docker run --rm -it \
  -e DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /path/to/renpy/project:/src \
  old6ix/renpy:8.0.3 /src
```

Apart from unix socket, you can also connect it to the X server by changing the container's network to host mode. This is all about X11, neither Ren'Py nor this image.

```bash
docker run --rm -it \
  --network host \
  -e DISPLAY \
  -v /path/to/renpy/project:/src \
  old6ix/renpy:8.0.3 /src
```

### Run as non-root user

It's usually not wise to run a container under the `root` user domain. Therefore, environment variables `PUID` and `PGID` are supported to be used in this image to map the container's internal user to a user on the host machine, just like images from [linuxserver.io](https://docs.linuxserver.io/general/understanding-puid-and-pgid/).

The following command will make distributions as user `1000` in group `1001`.

```bash
docker run --rm -it \
  -e PUID=1000 -e PGID=1001 \
  -v ${PWD}/out:/out \
  old6ix/renpy:8.0.3 launcher distribute ./the_question --dest /out
```

*Note: Because of volume permissions in Docker, the output directory has to be created and is writable by the running user before executing this command, only except in rare cases.*

## Development

### Build the image

```bash
export RENPY_VERSION=8.0.3  # expected version
docker build \
  -t old6ix/renpy:$RENPY_VERSION \
  --build-arg RENPY_VERSION=$RENPY_VERSION \
  .
```
