# Support the ⚡️-Network, serve cfilters using bitcoin core now!

**Why?** [Compact block filters](https://bitcoinops.org/en/topics/compact-block-filters/), or "cfilters" for short, support new [neutrino](https://github.com/lightninglabs/neutrino/)-style bitcoin light clients and are considered a huge improvement compared to traditional [SPV light clients](https://bitcoin.org/en/glossary/simplified-payment-verification), especially from a privacy perspective. Further, these filters power many lightning mobile wallets, which are mostly served by a single `btcd` full-node operated by the wallet vendor, since close to nobody is serving these filters as of now. Far from ideal. This project aims to change this by making it easy to serve cfilters using bitcoin core and convince some more folks to spin up a new node and [serve cfilters publicly](./mainnet) and reverse Luke Dashjr's [concerns](https://github.com/bitcoin/bitcoin/pull/18876#issuecomment-625893978) to the contrary.

**What?** It is already possible to serve cfilters with [bitcoin core](https://github.com/bitcoin/bitcoin/), running [this branch](https://github.com/jimpo/bitcoin/tree/bip157-net) by [Jim Posen](https://github.com/jimpo/). I am running it since a bit longer than a month without any issues. While you can [compile the branch](https://github.com/bitcoin/bitcoin/blob/master/doc/build-unix.md) yourself and run bitcoin core natively, this project focuses on doing so with [docker](https://www.docker.com/), which turns out to be pretty simple and additionally keeps your system clean from bitcoin core's build dependencies.

### Requirements:
- `docker --version` 18.06.0+
- 500 GB free disk space, better more

## Option a: Use pre-built images
- download above `docker-compose.yml` file, e.g. with
```
curl https://raw.githubusercontent.com/kilrau/bitcoind-cfilters/master/docker-compose.yml -o ~/docker-compose.yml
```
- in this file, adjust the directory to a path where you have enough free disk space and want bitcoin core to store blocks, e.g. from `/media/HDD/bitcoind` -> `~/.bitcoin`
- adjust `PID` & `GID` to the docker user's (`id -u <dockeruser> && id -g <dockeruser>`)
- `docker-compose up -d`
- once it's synced, add your node to [the list](./mainnet).

## Option b: Don't trust, build yourself
- download above `Dockerfile` or just clone the repo with `git clone https://github.com/kilrau/bitcoind-cfilters`
- check the `Dockerfile` and see for yourself that it is indeed building https://github.com/jimpo/bitcoin/tree/bip157-net
- `docker build . -t bitcoind && docker tag bitcoind:latest bitcoind:cfilters` (the build takes a moment)
- in `docker-compose.yml` remove the line `image: kilrau/bitcoind:cfilters` and uncomment the next line to use your local image and adjust `PID` & `GID` to the docker user's (`id -u <dockeruser> && id -g <dockeruser>`)
- `docker-compose up -d`
- once it's synced, add your node to [the list](./mainnet).

### Tipps 'n Tricks:
- you can run `bitcoin-cli` commands, e.g. `bitcoin-cli getblockchaininfo` using `docker exec -it bitcoind_mainnet_1 bitcoin-cli getblockchaininfo` to e.g. check on the sync progress
- known issue: when you need to restart an in-sync node on this branch, you'll have to temporarily remove the `-peercfilters` option, wait until the sync is done and then add it back
- to serve cfilters on bitcoin testnet, simply uncomment the lines in the docker-compose file

### TODO:
- [x] basic docker setup
- [ ] add tor
- [ ] monitor progress of [PR 18876](https://github.com/bitcoin/bitcoin/pull/18876), change images to bitcoin core master once everything is in
- [ ] add dns seed entries to btcd/neutrino serving lists above, open to ideas how else cfilter nodes could be served upfront without requiring `neutrino.addpeer`
