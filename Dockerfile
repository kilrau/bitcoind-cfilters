FROM alpine:3.11 as builder
RUN apk --no-cache add musl-dev g++ make autoconf automake libtool pkgconfig boost-dev libressl-dev libevent-dev zeromq-dev git
RUN git clone -b bip157-net --depth 1 https://github.com/jimpo/bitcoin.git
WORKDIR /bitcoin
RUN ./autogen.sh
RUN ./configure --disable-ccache --disable-tests --disable-bench --without-gui --with-daemon --with-utils --without-libs --disable-wallet
RUN make -j$(nproc)
RUN make install
RUN strip /usr/local/bin/bitcoind /usr/local/bin/bitcoin-cli

FROM alpine:3.11
RUN apk --no-cache add boost-system boost-filesystem boost-chrono boost-thread libevent libressl zeromq
COPY --from=builder /usr/local/bin/bitcoind /usr/local/bin/bitcoin-cli /usr/local/bin/
ENTRYPOINT ["bitcoind"]
