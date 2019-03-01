FROM ubuntu:18.04

ARG rust_home
ARG rustup_home
ARG cargo_home
ARG cargo_bin

ENV RUST_HOME $rust_home
ENV RUSTUP_HOME $rustup_home
ENV CARGO_HOME $cargo_home
ENV CARGO_BIN $cargo_bin

RUN apt-get update
RUN apt-get install -y \
  curl bash build-essential sudo

ENV PATH "$PATH:${CARGO_BIN}"

#################################### ATOM #####################################
COPY atom.deb /tmp/atom.deb

RUN apt-get install -y ca-certificates curl fakeroot gconf2 gconf-service git \
    gvfs-bin libasound2 libcap2 libgconf-2-4 libgtk2.0-0 libnotify4 libnss3 \
    libxkbfile1 libxss1 libxtst6 libgl1-mesa-glx libgl1-mesa-dri python \
    xdg-utils libcanberra-gtk3-module libudev1 libx11-xcb1 libsecret-1-0 \
    gir1.2-gnomekeyring-1.0

RUN apt-get install -y /tmp/atom.deb && rm /tmp/atom.deb

COPY docker-files/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
