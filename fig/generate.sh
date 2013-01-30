#!/bin/bash
qrencode -o main.png -s 50 "http://www.malloc47.com"
mogrify -crop 1250x1250+200+200 main.png
