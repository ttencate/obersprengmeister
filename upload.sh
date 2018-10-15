#!/bin/bash

cd "$(dirname "$0")"

set -e

export=./export

rsync -rpltv --delete $export/ frozenfractal.com:/var/www/obersprengmeister.frozenfractal.com/
