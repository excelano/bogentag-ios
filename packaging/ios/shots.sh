#!/bin/sh
# The App Store screenshots, as recipes. shots-appstore builds the app for the
# simulator, boots each simulator ship.toml names, installs the app, and calls
# this with the simulator, the language and where the frames go. The scenes
# are the Debug launch arguments the app reads: on the iPhone and iPad,
# Bogentag/CalendarDemo.swift's made-up week in Houston, opened on a November
# Wednesday, then the dial and the tour on Shared/Support/Demo.swift's worked
# day; on the watch, embedded in the iPhone app, Houston on that worked day,
# each dial and the civil view over each.
#
#     ./packaging/ios/shots.sh --app <Bogentag.app> --device <udid> --lang en-us --outdir <dir>
#
# Author: David M. Anderson
# Built with AI assistance (Claude, Anthropic)
set -eu
app= device= lang= outdir=
while [ $# -gt 0 ]; do
    case "$1" in
        --app) app=$2; shift 2 ;;
        --device) device=$2; shift 2 ;;
        --lang) lang=$2; shift 2 ;;
        --outdir) outdir=$2; shift 2 ;;
        *) echo "shots.sh: unknown argument $1" >&2; exit 2 ;;
    esac
done
[ -n "$app" ] && [ -n "$device" ] && [ -n "$lang" ] && [ -n "$outdir" ] || { echo "shots.sh: --app, --device, --lang and --outdir are all required" >&2; exit 2; }
case "$lang" in
    en|en-us|en-US) languages='(en)'; locale=en_US ;;
    *) echo "shots.sh: no set is written for $lang" >&2; exit 2 ;;
esac
case "$(xcrun simctl list devices | grep -F "($device)" | head -1)" in
    *Watch*) bundle=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$app"/Watch/*.app/Info.plist); watch=yes ;;
    *) bundle=$(/usr/libexec/PlistBuddy -c 'Print CFBundleIdentifier' "$app/Info.plist"); watch= ;;
esac
mkdir -p "$outdir"
settle=6
shot() {
    name=$1
    shift
    xcrun simctl launch --terminate-running-process "$device" "$bundle" \
        -AppleLanguages "$languages" -AppleLocale "$locale" "$@" >/dev/null
    sleep "$settle"
    xcrun simctl io "$device" screenshot --type=png "$outdir/$name.png" >/dev/null
    echo "$name"
}
if [ -n "$watch" ]; then
    shot 01-spans --demo
    shot 02-kiloseconds --demo --page kiloseconds
    shot 03-civil --demo --civil
    shot 04-kiloseconds-civil --demo --page kiloseconds --civil
    shot 05-day --demo --page day
else
    shot 01-today --demo
    shot 02-whole-day --demo --zoom 1.5
    shot 03-event --demo --event "Design review"
    shot 04-june --demo --date 2026-06-17
    shot 05-dial --demo --page spans
    shot 06-tour --demo --page tour
fi
xcrun simctl terminate "$device" "$bundle" >/dev/null 2>&1 || true
