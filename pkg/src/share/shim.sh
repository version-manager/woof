#!/usr/bin/env bash

exec=$(woof tool get-exe "${0##*/}")
if [ -n "$exec" ]; then
   exec -a "${exec##*/}" "$exec" "$@"
else
   printf '%s\n' 'Woof: Error: Failed to get executable'
fi
