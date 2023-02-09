#!/usr/bin/env bash

# stop on errors
set -eu

openssl enc -d -base64 -pbkdf2 -aes-256-cbc -salt  -in ./private.tgz.enc -out ./private.tgz
tar xzf ./private.tgz


