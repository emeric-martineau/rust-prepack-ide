#!/usr/bin/env bash

# Print tick in green.
print_ok() {
  echo " ${GREEN}✔${RESET}"
}

# Print cross in red.
print_ko() {
  echo " ${RED}✗${RESET}"
}

RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
TMP_RUST_CHANNEL="${HOME}/.rust.channel"
