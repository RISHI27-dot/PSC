#!/bin/bash

cd /run/media/sda1/audio/
amixer sset PCM 90%
amixer sset 'Left PGA Mixer Mic3R' on
amixer sset 'Right PGA Mixer Mic3R' on
amixer sset PGA 90%

aplay audio_src_file_s16le_44100.wav

arecord -f S16_LE -r 44100 -c 2 -d 5 record.wav

aplay record.wav
