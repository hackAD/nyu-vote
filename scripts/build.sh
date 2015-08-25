#!/bin/bash

# Builds the new docker environment

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
docker build -t hackad/nyu-vote $DIR/../
