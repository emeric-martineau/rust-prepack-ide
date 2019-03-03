# Rust prepack IDE

This project help you to have in few minutes a full Rust dev environment.

By default, this project create a Docker image with Atom and minimum plugins for Rust.

## Setup

Edit `config.cfg` file:
 - `ATOM_VERSION` : version of Atom you want install,
 - `ATOM_PACKAGE` : plugins package. Add yours.
 - `SOURCE_FOLDER` : your folder on host with your source files,
 - `DOCKER_IMAGE_NAME` : name of Docker image that will be create,
 - `DOCKER_RUST_HOME_VOLUME_NAME` : Docker volume contains all files for Rust,
 - `DOCKER_ATOM_HOME_VOLUME_NAME` : Docker volume to store your home in Docker container cause Atom store many files in,
 - `RUST_HOME` : folder of Rust installation that store in `DOCKER_RUST_HOME_VOLUME_NAME` Docker volume,
 - `RUSTUP_HOME` : Rust home,
 - `CARGO_HOME` : Rust cargo home,
 - `CARGO_BIN` : Cargo binary path add in `PATH` environment variable,
 - `RUST_STABLE_CHANEL_VERSION` : stable channel that you install (empty to install latest),
 - `RUSTUP_COMPONENTS` : Additional Rustup components,
 - `CARGO_COMPONENTS` : Cargo components.

## Build image

To build image, run `build.sh` script and wait because, it takes long time :)

## Run container

To run Atom, run `run.sh` script.

## How it's works

To store all Rust channel, Rustup component, Cargo dependencies... A Docker volume was created.

Atom store also many configuration (like open file, plugins config...) in `~/.config` folder. Another Docker volume was created.
