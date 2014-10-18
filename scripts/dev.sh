#!/bin/bash

# Starts the code
# Mounts this directory inside the image

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
docker run -i -t --rm --name nyu-vote -p 3000:3000 -v $DIR/../:/srv/nyu-vote/ lingz/nyu-vote bash
