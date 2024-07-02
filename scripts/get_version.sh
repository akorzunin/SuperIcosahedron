#!/bin/bash

if [[ "$1" == "--short" ]]; then
    echo $(git rev-parse --short --verify HEAD)
    exit 0
fi

if [[ "$1" == "--tag" ]]; then
    echo $(git describe --tags $(git rev-list --tags --max-count=1))
    exit 0
fi

echo Version: $(git rev-parse --short --verify HEAD) Latest tag: $(git describe --tags $(git rev-list --tags --max-count=1)) at $(git branch --show-current )
