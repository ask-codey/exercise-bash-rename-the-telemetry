#!/usr/bin/env bash
# rename.sh: renames every .tmp file in a folder so that it ends in .log instead.
#
# Usage:   ./rename.sh FOLDER
# Example: ./rename.sh telemetry
#
# What it must do:
#   1. Go through every file in the folder it's given ($1) whose name ends in .tmp,
#      with a for loop.
#   2. Rename each one to end in .log: orbit-01.tmp becomes orbit-01.log.
#      Names with spaces in them must work too.
#   3. Print a line for each file it renames, such as:  Renamed telemetry/orbit-01.tmp
#   4. At the end, print how many files it renamed, exactly like this:  Files renamed: 21
#   5. Be safe to run twice: when there's no .tmp file left, print  Files renamed: 0
#      and nothing else, with no error.
#
# Write your script under this line.
