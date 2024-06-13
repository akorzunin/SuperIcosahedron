#!/bin/bash

if [[ "$1" == "--short" ]]; then
    echo $(git rev-parse --short --verify HEAD)
    exit 0
fi

echo Version: $(git rev-parse --short --verify HEAD) at $(git branch --show-current )
