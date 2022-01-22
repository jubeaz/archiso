#!/usr/bin/env bash

# stop on errors
set -eu

openssl enc -d -base64 -pbkdf2 -aes-256-cbc -salt  -in ./secrets.sh -out ./public.sh

