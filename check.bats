#!/usr/bin/env bats
# Checks your two scripts, rename.sh and warnings.sh, and the work you did with them.
# Each script is tried for real on its own made-up files, in a throwaway folder, so
# nothing in this folder is changed by the check. The last two checks look at this
# folder's telemetry/ and warnings.txt, after you've run your scripts on them.
# Run it from this folder with:  bats check.bats
# You don't need to change this file.

setup() {
  cd "$BATS_TEST_DIRNAME"
  dir="$BATS_TEST_TMPDIR/practice"
  mkdir -p "$dir"
}

# Runs one of your scripts with bash, so it works whether or not you've made it runnable.
run_script() {
  local script="$1"
  shift
  bash "$BATS_TEST_DIRNAME/$script" "$@"
}

# A script's lines without its comments, so the instructions at the top don't count as code.
code_of() {
  grep -v '^[[:space:]]*#' "$1"
}

# A made-up telemetry folder: four .tmp files (one with spaces in its name) and two
# files that must be left alone.
make_telemetry() {
  mkdir -p "$dir/downlink"
  printf 'orbit 7: altitude 405 km\n' > "$dir/downlink/orbit-07.tmp"
  printf 'orbit 8: altitude 410 km\n' > "$dir/downlink/orbit-08.tmp"
  printf 'orbit 9: altitude 403 km\n' > "$dir/downlink/orbit-09.tmp"
  printf 'orbit 9 again\n' > "$dir/downlink/orbit 09 second copy.tmp"
  printf 'already done\n' > "$dir/downlink/orbit-06.log"
  printf 'keep me\n' > "$dir/downlink/notes.txt"
}

# A made-up flight log, different from flight-log.txt, with notes, indented lines,
# a backslash, and lines after END OF FLIGHT.
make_log() {
  printf '%s\n' \
    '# ground station 5, night shift' \
    'orbit 30: altitude 404 km' \
    '    WARNING: heater 2 is slow' \
    '# WARNING: this note is not a warning' \
    'orbit 31: altitude 406 km' \
    'WARNING: file D:\saved\orbit-31.raw is empty' \
    '  all normal' \
    'orbit 32: WARNING radio dropped for 40 seconds' \
    'END OF FLIGHT' \
    '  WARNING: after the end, never printed' > "$dir/night.log"
}

@test "rename.sh and warnings.sh are here" {
  for f in rename.sh warnings.sh; do
    if [[ ! -f "$f" ]]; then
      echo "$f is missing. Download the exercise again to get it back."
      return 1
    fi
  done
}

@test "1) rename.sh renames every .tmp file in the folder it's given" {
  make_telemetry
  run_script rename.sh "$dir/downlink" > /dev/null 2>&1 || true
  left="$(cd "$dir/downlink" && ls -- *.tmp 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "$left" -ne 0 ]]; then
    echo "After rename.sh, $left .tmp files are still there. Loop over every file in \"\$1\" that ends in .tmp, and mv each one."
    return 1
  fi
  for name in orbit-07 orbit-08 orbit-09; do
    if [[ ! -f "$dir/downlink/$name.log" ]]; then
      echo "$name.tmp should have become $name.log. The new name is the old one with .tmp cut off, \"\${f%.tmp}\", then .log."
      return 1
    fi
  done
  if [[ ! -f "$dir/downlink/orbit 09 second copy.log" ]]; then
    echo "'orbit 09 second copy.tmp', a name with spaces, wasn't renamed to 'orbit 09 second copy.log'. Put \"\$f\" and the new name in double quotes."
    return 1
  fi
  if [[ "$(cat "$dir/downlink/orbit-07.log")" != 'orbit 7: altitude 405 km' ]]; then
    echo "orbit-07.log doesn't hold what orbit-07.tmp held. Rename with mv; don't make a new file."
    return 1
  fi
  if [[ ! -f "$dir/downlink/notes.txt" || ! -f "$dir/downlink/orbit-06.log" ]]; then
    echo "rename.sh changed files that don't end in .tmp. Only the .tmp files should change."
    return 1
  fi
}

@test "2) rename.sh prints how many files it renamed" {
  make_telemetry
  last="$(run_script rename.sh "$dir/downlink" 2>/dev/null | tail -n 1)"
  if [[ "$last" != "Files renamed: 4" ]]; then
    echo "With four .tmp files, the last line should be: Files renamed: 4"
    echo "It was: $last"
    echo "Start a counter at 0 before the loop, add 1 for each file inside it, and print it after done."
    return 1
  fi
}

@test "3) rename.sh is safe to run twice" {
  make_telemetry
  run_script rename.sh "$dir/downlink" > /dev/null 2>&1 || true
  errors="$(run_script rename.sh "$dir/downlink" 2>&1 >/dev/null)"
  last="$(run_script rename.sh "$dir/downlink" 2>/dev/null | tail -n 1)"
  if [[ ! -f "$dir/downlink/orbit-07.log" ]]; then
    echo "rename.sh didn't rename the files the first time yet: check 1) first."
    return 1
  fi
  if [[ -n "$errors" ]]; then
    echo "Run again with no .tmp file left, rename.sh printed an error:"
    echo "$errors" | head -n 1
    echo "When no file matches, \$f is the pattern itself. Skip it with [[ -e \$f ]] || continue."
    return 1
  fi
  if [[ "$last" != "Files renamed: 0" ]]; then
    echo "Run again with no .tmp file left, the last line should be: Files renamed: 0"
    echo "It was: $last"
    return 1
  fi
}

@test "4) rename.sh uses a for loop" {
  if ! code_of rename.sh | grep -Eq '^[[:space:]]*for[[:space:]]'; then
    echo "rename.sh has no for loop yet. Start one with: for f in ... ; do"
    return 1
  fi
}

@test "5) warnings.sh prints each warning exactly as written" {
  make_log
  out="$(run_script warnings.sh "$dir/night.log" 2>/dev/null)"
  if ! grep -qxF '    WARNING: heater 2 is slow' <<< "$out"; then
    echo "The line '    WARNING: heater 2 is slow', with its four spaces at the start, isn't in the output."
    echo "Read each line with while IFS= read -r line, and print it with echo \"\$line\", in double quotes."
    return 1
  fi
  if ! grep -qxF 'WARNING: file D:\saved\orbit-31.raw is empty' <<< "$out"; then
    echo "The line 'WARNING: file D:\\saved\\orbit-31.raw is empty' isn't in the output with its backslashes. read needs -r to keep them."
    return 1
  fi
  if ! grep -qxF 'orbit 32: WARNING radio dropped for 40 seconds' <<< "$out"; then
    echo "The line 'orbit 32: WARNING radio dropped for 40 seconds' is missing. WARNING can be anywhere in a line: test with [[ \$line == *WARNING* ]]."
    return 1
  fi
  if grep -qF 'all normal' <<< "$out"; then
    echo "warnings.sh printed a line without WARNING in it. Print only the lines that have it."
    return 1
  fi
}

@test "6) warnings.sh skips the notes that start with #" {
  make_log
  out="$(run_script warnings.sh "$dir/night.log" 2>/dev/null)"
  if [[ -z "$out" ]]; then
    echo "warnings.sh printed nothing yet. Start with check 5)."
    return 1
  fi
  if grep -qF '# WARNING: this note is not a warning' <<< "$out"; then
    echo "warnings.sh printed a note that starts with #. Skip those lines with continue: [[ \$line == \"#\"* ]]."
    return 1
  fi
}

@test "7) warnings.sh stops at END OF FLIGHT" {
  make_log
  out="$(run_script warnings.sh "$dir/night.log" 2>/dev/null)"
  if [[ -z "$out" ]]; then
    echo "warnings.sh printed nothing yet. Start with check 5)."
    return 1
  fi
  if grep -qF 'after the end, never printed' <<< "$out"; then
    echo "warnings.sh printed a warning from after END OF FLIGHT. Leave the loop with break when the line is END OF FLIGHT."
    return 1
  fi
}

@test "8) warnings.sh prints how many warnings it found" {
  make_log
  last="$(run_script warnings.sh "$dir/night.log" 2>/dev/null | tail -n 1)"
  if [[ "$last" != "Warnings found: 3" ]]; then
    echo "This log has three warnings before END OF FLIGHT, so the last line should be: Warnings found: 3"
    echo "It was: $last"
    echo "Count each warning you print, and print the count after done."
    return 1
  fi
}

@test "9) warnings.sh reads the log with while IFS= read -r" {
  if ! code_of warnings.sh | grep -Eq 'while[[:space:]]+IFS=[[:space:]]+read[[:space:]]+-r'; then
    echo "warnings.sh doesn't read the log with while IFS= read -r line yet. Feed the file in after done: done < \"\$1\""
    return 1
  fi
}

@test "10) the telemetry folder is renamed" {
  tmp="$(ls telemetry/*.tmp 2>/dev/null | wc -l | tr -d ' ')"
  log="$(ls telemetry/*.log 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "$tmp" -ne 0 || "$log" -ne 21 ]]; then
    echo "telemetry/ has $tmp .tmp files and $log .log files; it should have 0 and 21. When checks 1) to 4) pass, run: ./rename.sh telemetry"
    return 1
  fi
}

@test "11) warnings.txt holds the flight log's warnings" {
  if [[ ! -f warnings.txt ]]; then
    echo "There's no warnings.txt yet. When checks 5) to 9) pass, save the report with: ./warnings.sh flight-log.txt > warnings.txt"
    return 1
  fi
  expected="$(awk '/^END OF FLIGHT$/ { exit } /^#/ { next } /WARNING/ { print; n++ } END { print "Warnings found: " n+0 }' flight-log.txt)"
  if [[ "$(cat warnings.txt)" != "$expected" ]]; then
    echo "warnings.txt doesn't match the warnings in flight-log.txt. Make it again with: ./warnings.sh flight-log.txt > warnings.txt"
    return 1
  fi
}
