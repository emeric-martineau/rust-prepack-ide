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
# return 0 if ok
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
    return 0
  else
    return 1
  fi
}

# Get last version of plugin for IntelliJ version.
#
# $1 IntelliJ version
# $2 Id of plugin
# $3 Plugin channel
#
# Set environment PLUGIN_DOWNLOAD_URL
get_last_plugin_version() {
  local channel="$3"
  local plugin_marketplace_url="${JET_BRAIN_PLUGINS_URL}/api/plugins/$2/updates?channel=${channel}"
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
    plugin_compat_version="$(echo ${plugin_compat_version} | sed 's/—/-/' | sed 's/build //' | sed 's/\*/9999/')"
    check_compatible_version "$1" "${plugin_compat_version}"

    if [ $? -eq 0 ]; then
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

# Download a plugin into /tmp/plugin.zip
#
# $1 url of plugin from rest api
# $2 output file
download_plugin() {
  local plugin_url="${JET_BRAIN_PLUGINS_URL}/files/$1"
  local filename="$2"

  echo -n "Download plugin..."

  curl "${plugin_url}" --output ${filename} 2>/dev/null

  if [ $? -eq 0 ]; then
    print_ok
    return 0
  else
    print_ko
    return 1
  fi
}

# Unpack plugin in folder of IntelliJ.
#
# $1 IntelliJ home
# $2 plugin file
unpack_plugin() {
  local intellij_home="$1"
  local plugins_dir="${intellij_home}/config/plugins/"
  mkdir -p "${plugins_dir}"

  echo -n "Unzip plugin..."

  # Remove plugin if already installed
  plugin_folder=$(unzip -Z1 $2 | head -1 | cut -d / -f 1)

  rm -rf "${plugins_dir}${plugin_folder}"

  unzip "$2" -d "${plugins_dir}" 2>/dev/null

  if [ ! $? -eq 0 ]; then
    print_ko
  fi
}

# Return home path of IntelliJ.
#
# echo home
get_intellij_home_path() {
  local productCode=$(cat ${PRODUCT_INFO} | jq '.productCode' | xargs)
  local version=$(cat ${PRODUCT_INFO} | jq '.version' | xargs)
  local version_majeur=$(get_number "${version}" 1)
  local version_min=$(get_number "${version}" 2)
  echo "${HOME}/.Idea${productCode}${version_majeur}.${version_min}"
}

# Install all plugin.
#
# $1 plugin list
# $2 channel
install_plugin() {
  local plugin_file="/tmp/plugin.zip"
  local intellij_home="$(get_intellij_home_path)"
  local channel="$2"

  for plugin in ${1}; do
    echo "Download IntelliJ plugin '${plugin}'"

    local plugin_url="$(get_plugin_url ${plugin})"

    if [ "null" = "${plugin_url}" ]; then
      print_ko
      exit 1
    else
      local plugin_id="$(echo ${plugin_url} | cut -d '-' -f 1 | cut -d '/' -f 3)"
      get_last_plugin_version "${INTELLIJ_VERSION}" "${plugin_id}" "${channel}"

      download_plugin "${PLUGIN_DOWNLOAD_URL}" "${plugin_file}"

      unpack_plugin "${intellij_home}" "${plugin_file}"
    fi
  done
}

REALPATH="$(realpath $0)"
BASEDIR="$(dirname ${REALPATH})"

. "${BASEDIR}/config.cfg"

if [ -n "$1" ]; then
  SCRIPTS_BASEDIR="$1/install-scripts"
else
  SCRIPTS_BASEDIR="${BASEDIR}/../../install-scripts"
fi

. "${SCRIPTS_BASEDIR}/common.sh"

# Check if apm is installed
if [ -z "$(command -v jq)" ]; then
  echo -n "Jq not found! Check 'jq' is in path "
  print_ko
  exit 1
fi

if [ -z "$(command -v unzip)" ]; then
  echo -n "Unzip not found! Check 'unzip' is in path "
  print_ko
  exit 1
fi

JET_BRAIN_PLUGINS_URL="https://plugins.jetbrains.com"
PRODUCT_INFO="/opt/intellij/product-info.json"

install_plugin "${PLUGINS}" "${PLUGINS_CHANNEL}"

rm -rf "${TMP_RUST_CHANNEL}"
