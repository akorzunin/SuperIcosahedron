#!/bin/bash

# Define the source and target files
SOURCE_FILE="assets/build/ost/section_change.wav"
TARGET_FILE="assets/build/ost/section_change_v1.wav"

# Define the speed adjustment factor

SPEED_FACTOR=1.95

# FFmpeg command to adjust speed and save the file
ffmpeg -i "$SOURCE_FILE" -filter:a \
    "asetrate=44100*$SPEED_FACTOR,aresample=44100,aresample=resampler=soxr:out_sample_rate=41000" \
    "$TARGET_FILE"
