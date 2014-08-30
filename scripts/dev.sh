#!/bin/bash

# Starts the code
# Mounts this directory inside the image

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
docker run -i -t --rm --name nyu-vote -v $DIR/../:/srv/nyu-vote/ lingz/nyu-vote
