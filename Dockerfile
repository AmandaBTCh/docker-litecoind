FROM ubuntu:xenial AS builder

ENV HOME /litecoin
ENV VERSION 0.15.1
ENV USER_ID 1000
ENV GROUP_ID 1000

RUN groupadd -g ${GROUP_ID} litecoin \
  && useradd -u ${USER_ID} -g litecoin -s /bin/bash -m -d /litecoin litecoin

RUN apt-get update && \
  apt-get install -y build-essential \
  libtool autotools-dev automake \
  pkg-config libssl-dev libevent-dev \
  bsdmainutils libboost-all-dev \
  software-properties-common && \
  add-apt-repository ppa:bitcoin/bitcoin && \
  apt-get update && \
  apt-get install -y libdb4.8-dev libdb4.8++-dev

RUN  curl -sL https://github.com/litecoin-project/litecoin/archive/v$VERSION.tar.gz | tar xz && mv /litecoin-$VERSION /litecoin

WORKDIR /litecoin

RUN ./autogen.sh
RUN ./configure \
  --disable-shared \
  --disable-static \
  --disable-tests \
  --disable-bench \
  --with-utils \
  --without-libs \
  --without-gui

RUN make -j$(nproc)
RUN strip src/litecoind src/litecoin-cli

FROM ubuntu:xenial 

COPY --from=builder /litecoin/src/litecoind /litecoin/src/litecoin-cli /usr/local/bin/

ENV GOSU_VERSION 1.7
RUN set -x \
  && apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates \
  wget \
  && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
  && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
  && export GNUPGHOME="$(mktemp -d)" \
  && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
  && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
  && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
  && chmod +x /usr/local/bin/gosu \
  && gosu nobody true \
  && apt-get purge -y \
  ca-certificates \
  wget \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/btc_oneshot
RUN chmod +x /usr/local/bin/litecoind
RUN chmod +x /usr/local/bin/litecoin-cli

VOLUME ["/litecoin"]

EXPOSE 9332 9333

WORKDIR /litecoin

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["ltc_oneshot"]