#!/usr/bin/env bash

# Search on JetBrain plugins market place link of plugin.
#
# $1 plugin name
#
# print url
get_plugin_url() {
  local plugin_marketplace_url="${JET_BRAIN_PLUGINS_URL}/search/suggest?product=idea_ce&term="
  local filename=/tmp/plugin_marketplace.json

  curl "${plugin_marketplace_url}$1" --output ${filename} 2>/dev/null

  local index=0
  local plugin_name="$(cat ${filename} | jq '.['${index}'].value' | xargs)"
  local plugin_url='null'

  # If 'null', index doesn't exists
  while [ "null" != "${plugin_name}" ]; do
    if [ "$1" = "${plugin_name}" ]; then
      # It's our plugin !
      plugin_url="$(cat ${filename} | jq '.['${index}'].data.url' | xargs)"

      # To break while
      plugin_name='null'
    else
      index=$(expr ${index} + 1)
      plugin_name="$(cat ${filename} | jq '.['${index}'].value')"
    fi
  done

  rm -f "${filename}"

  echo ${plugin_url}
}

# Get number from XXXX.YY.ZZ. If not set, get 0.
#
# $1 version
# $2 field number
get_number() {
  local v=$(echo ${1} | cut -d '.' -f $2)

  echo ${v:-0}
}

# Check if current version of plugin compatible with IntelliJ version.
#
# $1 Current IntelliJ version
# $2 Version of IntelliJ supported by plugin
#
# Set environment variable IS_COMPATIBLE
check_compatible_version() {
  local mini_version="$(echo $2 | cut -d '-' -f 1 | xargs)"
  local mini_major_version=$(get_number "${mini_version}" 1)
  local mini_minor_version=$(get_number "${mini_version}" 2)
  local mini_fix_version=$(get_number "${mini_version}" 3)

  # In JSON, version are separated by UTF8 character
  local max_version="$(echo $2 | cut -d '-' -f 2 | xargs)"
  local max_major_version=$(get_number "${max_version}" 1)
  local max_minor_version=$(get_number "${max_version}" 2)
  local max_fix_version=$(get_number "${max_version}" 3)

  local current_major_version=$(get_number ${1} 1)
  local current_minor_version=$(get_number ${1} 2)
  local current_fix_version=$(get_number ${1} 3)

  # Our IntelliJ version is upper or equal of minimum
  if
    # Our IntelliJ major version is upper or equal of minimum
    ([ ${mini_major_version} -lt ${current_major_version} ] ||
    [ ${mini_major_version} -eq ${current_major_version} ]) &&
    # Our IntelliJ major version is less or equal of maximum
    ([ ${max_major_version} -gt ${current_major_version} ] ||
    [ ${max_major_version} -eq ${current_major_version} ]) &&
    # Our IntelliJ minor version is upper or equal of minimum
    ([ ${mini_minor_version} -lt ${current_minor_version} ] ||
     [ ${mini_minor_version} -eq ${current_minor_version} ]) &&
    # Our IntelliJ minor version is less or equal of maximum
    ([ ${max_minor_version} -gt ${current_minor_version} ] ||
     [ ${max_minor_version} -eq ${current_minor_version} ]) &&
     # Our IntelliJ fix version is upper or equal of minimum
     ([ ${mini_fix_version} -lt ${current_fix_version} ] ||
      [ ${mini_fix_version} -eq ${current_fix_version} ]) &&
     # Our IntelliJ fix version is less or equal of maximum
     ([ ${max_fix_version} -gt ${current_fix_version} ] ||
      [ ${max_fix_version} -eq ${current_fix_version} ])
    then
    IS_COMPATIBLE="true"
  else
    IS_COMPATIBLE="false"
  fi
}

# Get last version of plugin for IntelliJ version.
#
# $1 IntelliJ version
# $2 Id of plugin
#
# Set environment PLUGIN_DOWNLOAD_URL
get_last_plugin_version() {
  local plugin_marketplace_url="${JET_BRAIN_PLUGINS_URL}/api/plugins/$2/updates?channel="
  local filename=/tmp/plugin.json

  curl "${plugin_marketplace_url}" --output ${filename} 2>/dev/null

  local index=0
  local plugin_version="$(cat ${filename} | jq '.['${index}'].version' | xargs)"
  local plugin_compat_version="$(cat ${filename} | jq '.['${index}'].compatibleVersions.IDEA_COMMUNITY' | xargs)"
  local plugin_url='null'

  # If 'null', index doesn't exists
  while [ "null" != "${plugin_compat_version}" ]; do
    echo -n "  - Check if version '${plugin_version}' is compatible"

    # Clean utf8 code and 'build ' prefix
    plugin_compat_version="$(echo ${plugin_compat_version} | sed 's/—/-/' | sed 's/build //')"
    check_compatible_version "$1" "${plugin_compat_version}"

    if [ "${IS_COMPATIBLE}" = "true" ]; then
      plugin_url="$(cat ${filename} | jq '.['${index}'].file' | xargs)"

      print_ok

      # To break while
      plugin_compat_version='null'
    else
      print_ko

      index=$(expr ${index} + 1)
      local plugin_version="$(cat ${filename} | jq '.['${index}'].version' | xargs)"
      local plugin_compat_version="$(cat ${filename} | jq '.['${index}'].compatibleVersions.IDEA_COMMUNITY' | xargs)"
    fi
  done

  rm -f "${filename}"

  PLUGIN_DOWNLOAD_URL="${plugin_url}"
}

install_plugin() {
  for plugin in ${1}; do
    echo "Download IntelliJ plugin '${plugin}' "

    local plugin_url="$(get_plugin_url ${plugin})"

    if [ "null" = "${plugin_url}" ]; then
      print_ko
      exit 1
    else
      local plugin_id="$(echo ${plugin_url} | cut -d '-' -f 1 | cut -d '/' -f 3)"
      get_last_plugin_version "${INTELLIJ_VERSION}" "${plugin_id}"

      # Download plugin https://plugins.jetbrains.com/files/"${PLUGIN_DOWNLOAD_URL}"
    fi
  done
}

REALPATH="$(realpath $0)"
BASEDIR="$(dirname ${REALPATH})"

. "${BASEDIR}/../config.cfg"
. "${BASEDIR}/common.sh"

# Check if apm is installed
if [ -z "$(command -v jq)" ]; then
  . "${BASEDIR}/common.sh"

  echo -n "Jq not found! Check 'jq' is in path "
  print_ko
  exit 1
fi

JET_BRAIN_PLUGINS_URL="https://plugins.jetbrains.com"

install_plugin "${INTELLIJ_PLUGIN}"

# https://plugins.jetbrains.com/search/suggest?product=idea_ce&term=toml
#   ="Rust Toml"
#
# - Rust: https://plugins.jetbrains.com/plugins/nightly/8182
# - TOML: https://plugins.jetbrains.com/plugins/nightly/8195
# https://plugins.jetbrains.com/search/suggest?product=&term=rust
# [{"value":"Rust","data":{"vendor":"JetBrains","url":"/plugin/8182-rust","target":"intellij"}},{"value":"Rust and Cargo Support","data":{"vendor":"JetBrains, s.r.o.","url":"/plugin/9044-rust-and-cargo-support","target":"teamcity"}}]
#
# jq '.[0].compatibleVersions.IDEA'
#
# sudo apt-get install jq
#
# channel ["nightly",""]
#
# https://plugins.jetbrains.com/api/plugins/8182/updates?channel=
#
# 1	{…}
# id	58269
# link	/plugin/8182-rust/update/58269
# version	0.2.92.2116-183
# approve	true
# listed	true
# cdate	1550149645000
# file	8182/58269/intellij-rust-0.2.92.2116-183.zip
# notes	<a href="https://intellij-rust.github.io/2019/02/14/changelog-92.html"> https://intellij-rust.github.io/2019/02/14/changelog-92.html </a>
# since	183.0
# until	183.*
# sinceUntil	183—183.*
# channel
# size	4803124
# compatibleVersions	{…}
# APPCODE	2018.3 — 2018.3.5
# IDEA_EDUCATIONAL	2018.3.1
# RIDER	2018.3 — 2018.3.3
# IDEA	2018.3 — 2018.3.5
# ANDROID_STUDIO	build 183.0 — 183.*
# RUBYMINE	2018.3 — 2018.3.5
# PYCHARM_EDUCATIONAL	2018.3
# CLION	2018.3 — 2018.3.4
# DBE	2018.3 — 2018.3.3
# PHPSTORM	2018.3 — 2018.3.4
# PYCHARM_COMMUNITY	2018.3 — 2018.3.5
# IDEA_COMMUNITY	2018.3 — 2018.3.5
# WEBSTORM	2018.3 — 2018.3.5
# GOLAND	2018.3 — 2018.3.5
# MPS	2018.3 — 2018.3.4
# PYCHARM	2018.3 — 2018.3.5
