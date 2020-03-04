#!/usr/bin/env bash


# Verify AWS CLI Credentials are setup
# http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html
function aws_check_config() {
    if ! grep -q aws_access_key_id ~/.aws/credentials; then
        fail "AWS config not found or CLI not installed. Please run \"aws configure\"."
    fi
}
