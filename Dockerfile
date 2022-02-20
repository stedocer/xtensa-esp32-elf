FROM ubuntu:18.04 AS builder

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  git \
  wget \
  libncurses-dev \
  flex \
  bison \
  gperf \
  python \
  python-dev \
  python-pip \
  python-setuptools \
  python-serial \
  python-click \
  python-cryptography \
  python-future \
  python-pyparsing \
  python-pyelftools \
  cmake \
  ninja-build \
  ccache \
  libffi-dev \
  libssl-dev \
  dfu-util \
  gawk \
  grep \
  gettext \
  automake \
  texinfo \
  help2man \
  libtool \
  libtool-bin \
  make \
  unzip

RUN mkdir /crosstool && \
  useradd --system --home-dir /crosstool crosstool  && \
  chown crosstool:crosstool /crosstool

WORKDIR /crosstool
USER crosstool

RUN git clone https://github.com/espressif/crosstool-NG.git . && \
  git checkout esp-2021r2-patch3 && \
  git submodule update --init && \
  sed -i 's/--enable-newlib-long-time_t//g' samples/xtensa-esp32-elf/crosstool.config && \
  ./bootstrap && \
  ./configure --enable-local && \
  make

RUN ./ct-ng xtensa-esp32-elf && ./ct-ng build


FROM scratch
COPY --from=builder /crosstool/builds/ /opt/
