FROM debian:stable-slim

ENV HOME /litecoin

ENV USER_ID 1000
ENV GROUP_ID 1000

RUN groupadd -g ${GROUP_ID} litecoin \
  && useradd -u ${USER_ID} -g litecoin -s /bin/bash -m -d /litecoin litecoin \
  && set -x \
  && apt-get update -y \
  && apt-get install -y curl gosu \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LITECOIN_VERSION=0.16.3

RUN curl -O https://download.litecoin.org/litecoin-${LITECOIN_VERSION}/linux/litecoin-${LITECOIN_VERSION}-x86_64-linux-gnu.tar.gz \
  && tar --strip=2 -xzf *.tar.gz -C /usr/local/bin \
  && rm *.tar.gz

ADD ./bin /usr/local/bin
RUN chmod +x /usr/local/bin/ltc_oneshot

VOLUME ["/litecoin"]

EXPOSE 9332 9333

WORKDIR /litecoin

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["ltc_oneshot"]