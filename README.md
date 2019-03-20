# Rust prepack IDE

This project help you to have in few minutes a full Rust dev environment.

By default, this project create a Docker image with editor and minimum plugins for Rust.

## Supported editor

- Atom,
- IntelliJ CE,
- Vim.

## Setup

Edit `config.cfg` file:
 - `SOURCE_FOLDER`: your folder on host with your source files,
 - `DOCKER_IMAGE_NAME`: name of Docker image that will be create,
 - `DOCKER_HOME_VOLUME_NAME`: Docker volume contains all files for Rust an your container home,
 - `RUST_STABLE_CHANEL_VERSION`: stable channel that you install (empty to install latest),
 - `RUSTUP_COMPONENTS`: Additional Rustup components,
 - `CARGO_COMPONENTS`: Cargo components.

## Editor setup

Edit `editors/<editor>/config.cfg` file:
 - `PLUGINS`: plugins list,
 - `PLUGINS_CHANNEL`: plugin channel,
 - `EXEC`: command to launch editor,
 - `DOWNLOAD_FILE`: name of editor file downloaded in `download` folder,
 - `DOWNLOAD_URL`: url of editor install file.

## Build image

To build image, run `build.sh <editor>` script and wait because, it takes long time :)

Editor, if need, is download in `download` folder to avoid download at each build.

## Run container

To run Atom, run `run.sh <editor>` script.

NOTE : you can to be root in container with `sudo su`. To run the shell instead of running the editor `run.sh <editor> --shell`

## Remove image

If you want remove image, just run `remove.sh` script.

You can keep Rust's Docker volume with parameter `--keep-rust-home-volume`.

## How it's works

To store all Rust channel, Rustup component, Cargo dependencies... in home user.

Many editor store also many configuration (like open file, plugins config...) in home folder.

A volume corresponding to the home user was created to store all these files.

## Install without Docker

If you don't want use Docker or you can't, you can use scripts to install editor's plugins,
you can run `editors/<editor>/install-plugin.sh` script.

To install Rust, run `install-scripts/install-rust.sh` script.

## Contributing

### Open issue first

Before create a PR, please make an issue to be sur you idea will be accepted and
that not another people work on.

### Add new Editor

If you want add a new editor, look in `editors` folder to see how it's work.

You mist create three files :
 - Dockerfile,
 - config.cfg
 - install-plugin.sh

 In `install-plugin.sh` the environment variable `TMP_RUST_CHANNEL` is file where
 `install-rust.sh` script write channel of rust.
