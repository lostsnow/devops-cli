#!/usr/bin/env bash

# Functions

# Check Command
function check_command() {
    type -P $1 &>/dev/null || fail "Unable to find $1, please install it and run this script again."
}

# Completed
function completed() {
    echo
    HorizontalRule
    tput setaf 2
    echo "Completed!" && tput sgr0
    HorizontalRule
    echo
}

# Info echo
function success_echo() {
    tput setaf 2
    echo "$*" && tput sgr0
}

# Info echo
function info_echo() {
    tput setaf 6
    echo "$*" && tput sgr0
}

# Warn echo
function warn_echo() {
    tput setaf 3
    echo "$*" && tput sgr0
}

# Fail
function fail() {
    tput setaf 1
    echo "Failure: $*" && tput sgr0
    exit 1
}

# Fail echo
function fail_echo() {
    tput setaf 1
    echo "Failure: $*" && tput sgr0
}

# Horizontal Rule
function HorizontalRule() {
    echo "============================================================"
}

# Pause
function pause() {
    read -n 1 -s -p "Press any key to continue..."
    echo
}