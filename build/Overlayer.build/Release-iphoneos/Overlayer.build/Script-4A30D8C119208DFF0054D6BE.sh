#!/bin/sh -e
mdfind -onlyin "${SRCROOT}" "kMDItemContentTypeTree == public.font" -0 | sort -z | xargs -0 /usr/local/bin/moarfonts install
