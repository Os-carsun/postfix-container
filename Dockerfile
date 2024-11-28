FROM debian:12 
#as build

ARG DEBUG=false
ARG POSTFIX_DL_SITE="https://de.postfix.org"
ARG POSTFIX_DL_PATH="ftpmirror/official"
ARG POSTFIX_VERSION="3.9.0"
ARG POSTFIX_TAR="postfix-${POSTFIX_VERSION}.tar.gz"
ARG POSTFIX_UID="5566"
ARG POSTFIX_GID="5566"
ARG POSTDROP_GID="9487"


COPY ./wietse_pgp_key.pgp /key.pgp

USER root

RUN groupadd -g ${POSTFIX_GID} postfix && \
    groupadd -g ${POSTDROP_GID} postdrop && \
    useradd -u ${POSTFIX_UID} -g ${POSTFIX_GID} -d /no/where -s /no/shell postfix

RUN apt-get update && \
    apt-get install gpg wget libdb-dev m4 build-essential libicu-dev libpcre3-dev pkg-config -y

RUN wget ${POSTFIX_DL_SITE}/${POSTFIX_DL_PATH}/${POSTFIX_TAR} && \
    wget ${POSTFIX_DL_SITE}/${POSTFIX_DL_PATH}/${POSTFIX_TAR}.gpg2

#GPG verification and untar soruce code
# trust wietse's key
RUN gpg --import /key.pgp && \
    echo "622C7C012254C186677469C50C0B590E80CA15A7:6:" | gpg --import-ownertrust && \
    gpg --verify ${POSTFIX_TAR}.gpg2 ${POSTFIX_TAR} && \
    tar -xvf ${POSTFIX_TAR}

WORKDIR postfix-${POSTFIX_VERSION}
RUN make makefiles pie=yes dynamicmaps=yes shared=yes DEBUG='-g' 
RUN make 
RUN make install -non-interactive && make upgrade
RUN make clean
