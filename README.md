# Rust prepack IDE

This project help you to have in few minutes a full Rust dev environment.

By default, this project create a Docker image with editor and minimum plugins for Rust.

## Supported editor

- Atom,
- IntelliJ CE.

## Setup

Edit `config.cfg` file:
 - `ATOM_VERSION` : version of Atom you want install,
 - `ATOM_PACKAGE` : plugins package. Add yours.
 - `SOURCE_FOLDER` : your folder on host with your source files,
 - `DOCKER_IMAGE_NAME` : name of Docker image that will be create,
 - `DOCKER_HOME_VOLUME_NAME` : Docker volume contains all files for Rust an your container home,
 - `RUST_STABLE_CHANEL_VERSION` : stable channel that you install (empty to install latest),
 - `RUSTUP_COMPONENTS` : Additional Rustup components,
 - `CARGO_COMPONENTS` : Cargo components.

## Build image

To build image, run `build.sh atom | intellij` script and wait because, it takes long time :)

Editor, if need, is download in root directory to avoid download at each build.

## Run container

To run Atom, run `run.sh atom` script.

NOTE : you can to be root in container with `sudo su`. To run the shell instead of running the editor `run.sh <editor> --shell`

## Remove image

If you want remove image, just run `remove.sh` script.

You can keep Rust's Docker volume with parameter `--keep-rust-home-volume`.

## How it's works

To store all Rust channel, Rustup component, Cargo dependencies... A Docker volume was created.

Atom store also many configuration (like open file, plugins config...) in `~/.config` folder.
Another Docker volume was created.

## Install without Docker

If you don't want use Docker or you can't, you can use scripts to install Atom plugins,
you can run `install-scripts/install-atom-plugin.sh` script.

To install IntelliJ plugins, you can run `install-scripts/install-intellij-plugin.sh` script.

To install Rust, run `install-scripts/install-rust.sh` script.
