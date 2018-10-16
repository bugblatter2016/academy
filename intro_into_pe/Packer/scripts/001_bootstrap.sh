#!/usr/bin/env bash

set -eux

# Function to replace configuration setting in config file or add the configuration setting if
# it does not exist.
#
# Expects four arguments:
#
# config_file:      Configuration file that will be modified
# key:          Configuration option to change
# value:        Value of the configuration option to change
# cce:          The CCE identifier or '@CCENUM@' if no CCE identifier exists
#
# Optional arugments:
#
# format:       Optional argument to specify the format of how key/value should be
#           modified/appended in the configuration file. The default is key = value.
#
# Example Call(s):
#
#     With default format of 'key = value':
#     replace_or_append '/etc/sysctl.conf' '^kernel.randomize_va_space' '2' '@CCENUM@'
#
#     With custom key/value format:
#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' 'disabled' '@CCENUM@' '%s=%s'
#
#     With a variable:
#     replace_or_append '/etc/sysconfig/selinux' '^SELINUX=' $var_selinux_state '@CCENUM@' '%s=%s'
#
function replace_or_append {
    local config_file=$1
    local key=$2
    local value=$3
    local cce=$4

    # Check sanity of the input
    if [ $# -lt "4" ]
    then
        echo "Usage: replace_or_append 'config_file_location' 'key_to_search' 'new_value' 'cce'"
        exit 1
    fi

    # Test if the config_file is a symbolic link. If so, use --follow-symlinks with sed.
    # Otherwise, regular sed command will do.
    if test -L $config_file; then
        sed_command="sed -i --follow-symlinks"
    else
        sed_command="sed -i"
    fi

    # Test that the cce arg is not empty or does not equal @CCENUM@.
    # If @CCENUM@ exists, it means that there is no CCE assigned.
    if ! [ "x$cce" = x ] && [ "$cce" != '@CCENUM@' ]; then
        cce="CCE-${cce}"
    else
        cce="CCE"
    fi

    # Strip any search characters in the key arg so that the key can be replaced without
    # adding any search characters to the config file.
    stripped_key=$(sed "s/[\^=\$,;+]*//g" <<< $key)

    formatted_output="$stripped_key = $value"

    # If the key exists, change it. Otherwise, add it to the config_file.
    if `grep -qi "$key" $config_file` ; then
        eval '$sed_command "s/$key.*/$formatted_output/g" $config_file'
    else
        # \n is precaution for case where file ends without trailing newline
        echo -e "\n# Per $cce: Set $formatted_output in $config_file" >> $config_file
        echo -e "$formatted_output" >> $config_file
    fi
}

# ensure that by default all yum repos will perform a gpg check of the package
# to ensure it hasn't been modified from the providers version
replace_or_append '/etc/yum.conf' '^gpgcheck' '1' 'CCE-26709-6'
sed -i 's/gpgcheck=.*/gpgcheck=1/g' /etc/yum.repos.d/*

# when we install an update via yum, we want to remove the old version from the
# system to keep everything nice and clean
replace_or_append '/etc/yum.conf', '^clean_requirements_on_remove' '1' '@CCENUM@'

# update all packages that have been installed via the yum package manager to
# the latest available versions
yum update -y

# configure the timezone of the operating system to be UTC
replace_or_append '/etc/sysconfig/clock' '^ZONE' 'UTC' '@CCENUM@'
ln -sf /usr/share/zoneinfo/UTC /etc/localtime