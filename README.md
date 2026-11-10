# Exercise: Rename the Telemetry

Exercise code for the lesson **Exercise: Rename the Telemetry** in Bash in Depth on [ask-codey.com](https://www.ask-codey.com).

It's launch day at Mission Control, and the ground station needs two small tools. The satellite's telemetry files came in ending in `.tmp` instead of `.log`, and the flight director wants every warning from last night's flight log in one short report. Write two scripts, `rename.sh` and `warnings.sh`, run them on the real files, and let a check script tell you what's done.

## Before you start

You need a terminal (the Terminal app on a Mac, Ubuntu on Linux or in WSL on Windows) and **bats**, the tool that runs the check. If `bats --version` doesn't print a version yet, install it:

```bash
sudo apt install bats       # Ubuntu, and Ubuntu in WSL
brew install bats-core      # a Mac, with Homebrew
```

**On Windows, unzip or clone this folder inside Ubuntu**, in your Linux home folder (for example `~/terminal-practice/`), not in a Windows folder under `/mnt/c`, so `chmod` works on the scripts.

## What's here

- `rename.sh`: renames every `.tmp` file in a folder to end in `.log`. For you to finish.
- `warnings.sh`: prints every warning in a flight log. For you to finish.
- `telemetry/`: the satellite's 21 telemetry files, all ending in `.tmp`. One has spaces in its name. Ready to use: your `rename.sh` renames them.
- `flight-log.txt`: last night's flight log. Ready to use: your `warnings.sh` reads it.
- `check.bats`: the check. You don't need to change it.

## Run it

Open a terminal in this folder (the one with `check.bats` in it), make the two scripts runnable, and open the first one:

```bash
chmod +x rename.sh warnings.sh
nano rename.sh
```

The comment at the top of each script says exactly what it must do. Write your lines under the last comment, save with Ctrl+O and Enter, and quit with Ctrl+X. Then try your script on a copy first, so a mistake can't touch the real files:

```bash
cp -r telemetry practice
./rename.sh practice
```

When it does what you want, delete the copy with `rm -r practice`, which deletes only that folder.

The jobs:

1. **`rename.sh FOLDER`** renames every `.tmp` file in the folder to end in `.log`, prints a line for each file it renames, and ends with `Files renamed: 21` (or however many it renamed). Run a second time, with nothing left to rename, it prints `Files renamed: 0` and no error.
2. **`warnings.sh LOGFILE`** reads the log one line at a time, skips the notes that start with `#`, stops at the line `END OF FLIGHT`, prints every other line with `WARNING` in it exactly as written, and ends with `Warnings found: 3` (or however many it printed).
3. **Use them.** When the checks for a script pass, run it on the real files:

   ```bash
   ./rename.sh telemetry
   ./warnings.sh flight-log.txt > warnings.txt
   ```

## Check your work

From this folder:

```bash
bats check.bats
```

At first most checks fail: that is expected. Each job you finish turns its checks into a ✓. A failing check's message says what to look at. The check tries each script on made-up files of its own in a throwaway folder; only the last two checks look at this folder's `telemetry/` and `warnings.txt`.

## The rules

- `rename.sh` uses a `for` loop, and `warnings.sh` reads the log with `while IFS= read -r line`.
- Each script works on the folder or file it's given as `$1`, not on a name written into the script.
- Print the last line of each script exactly as shown: `Files renamed: N` and `Warnings found: N`.

## Tips

- In `for f in "$1"/*.tmp`, the double quotes go around `$1` only, so a folder name with spaces works and the `*` still matches.
- `"${f%.tmp}.log"` is `$f` with `.tmp` cut off the end, then `.log`.
- A counter starts at 0 before the loop: `count=0`. Inside, `count=$((count + 1))`. After `done`, print it.
- When no file matches, `$f` is the pattern itself. `[[ -e $f ]] || continue` skips it.
- Inside `[[ ]]`, `$line == "#"*` is "starts with #", and `$line == *WARNING*` is "has WARNING somewhere in it".
- `break` leaves the loop; `continue` skips to the next line.
- Not sure what your loop will do? Put `echo` in front of `mv` and run it on your `practice` copy first.

## Hand it in

When it works, push your solution to a public repo of your own on GitHub, then paste that repo's address into **Submit your exercise** on the lesson page at [ask-codey.com](https://www.ask-codey.com). That's what completes the lesson. The lesson page shows the Git commands, step by step.
