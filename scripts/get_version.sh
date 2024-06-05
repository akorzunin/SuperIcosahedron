#!/bin/sh

echo Version: $(git rev-parse --short --verify HEAD) at $(git branch --show-current )
