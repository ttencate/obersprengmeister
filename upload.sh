#!/bin/bash

cd "$(dirname "$0")"
rsync -rpltv --delete ./export/ frozenfractal.com:/var/www/obersprengmeister.frozenfractal.com/
