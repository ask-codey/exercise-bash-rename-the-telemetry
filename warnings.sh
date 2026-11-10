#!/usr/bin/env bash
# warnings.sh: prints every warning in a flight log, exactly as it was written.
#
# Usage:   ./warnings.sh LOGFILE
# Example: ./warnings.sh flight-log.txt
#
# What it must do:
#   1. Read the log ($1) one line at a time, with while IFS= read -r line.
#   2. Skip every line that starts with # (they're notes from the night shift).
#   3. Stop reading at the line END OF FLIGHT: anything after it is a test, not the flight.
#   4. Print every other line that has WARNING in it, exactly as written, with its
#      spaces at the start and its backslashes.
#   5. At the end, print how many warnings it printed, exactly like this:  Warnings found: 3
#
# Write your script under this line.
