# CLAUDE.md

Bogentag is the iPhone, iPad and Apple Watch app for Bogenzeit, the time standard whose spec,
reference and vectors are in excelano/bogenzeit; the spec there is normative and no definition in it
changes without David. On the iPhone and iPad it opens on a calendar that shows the calendars on
the device, read through EventKit, laid out in Bogenzeit (`docs/concept.md`), with the dial, its timer
and stopwatch and the About Bogenzeit tour in a second tab; its widgets and the timer's Live Activity
are in `BogentagPhoneWidgets/`. On the watch the dial is the main screen, with the timer, stopwatch,
day and settings pages and the complications (`Bogentag Watch App/`, `BogentagWidgets/`).
`docs/bogentag-spec.md` is the face spec. `Bogentag/` holds what only the iPhone and iPad app
compiles, and `Shared/` what it shares with the watch app; each widget extension takes its files
from `Shared/` by name in the project file. The engine, the display forms (`Scale`, `Precision`,
`DisplayedPosition`) and the drawn glyphs come from the Swift package excelano/bogenzeit-swift,
depended on by URL; a change to any of them is made there and released as a new tag.

The only events Bogentag creates are moments, zero-length events with an alert at their start, set
from the day column. An event's start and end are set in Bogenzeit from its details; everything else
about it is changed, and it is deleted, in the system's event editor (`EKEventEditViewController`),
opened from there too.

## Commands

    xcremote build                                  # the iPhone scheme, watch app embedded
    xcremote install                                # onto David's iPhone and watch, as ~/notes/shipping.md says
    xcodebuild test -scheme "Bogentag Watch App"    # on the Mac, on a watch simulator; reboot the simulator after

`ship.toml` (gitignored) carries the API key xcremote signs with. Signing is automatic. Each app and
its own widgets share the app group `BOGENTAG_APP_GROUP` (`Config/Bogentag.xcconfig`, named again in
`Shared/Support/AppGroup.swift`).

A Debug build launched with `--demo` shows a made-up week in Houston in the calendar and Houston on
the spec's worked day on the dial; `packaging/ios/shots.sh` takes the store screenshots from both. The
calendar takes `--date`, `--zoom` and `--event`. `--page spans` or `kiloseconds` opens on that dial (the
Dial tab on the iPhone), and `--civil` and `--precision` (`low`, `medium`, `high`) set it; on the iPhone
`--page timer`, `stopwatch`, `tour` (with `--tour-page`) or `gallery`, which renders every widget at its
sizes, and on the watch `--page timer`, `stopwatch`, `day` or `settings`.

The icon is drawn in `Icon/AppIcon.svg`, which renders both `icon-light.png` and
`icon-dark.png` and the watch's `AppIcon.png`, and `Icon/AppIcon-tinted.svg`. Render
one into its `Assets.xcassets/AppIcon.appiconset/` with
`rsvg-convert -w 1024 -h 1024 <svg> | magick - -alpha off -strip PNG24:<png>`.

## Rules

The day view gives every span the same height, from the starting ○ to the ending ○ (spec §3.8), and
falls back to an even ○-to-○ axis on a polar day. Displayed spans and kiloseconds are the floor of the
signed value, so an anchor or event shows only once it has been reached. Position replaces sign: number
left of the glyph is before, right is after, no `+` or `−`. Views that can hold a drawing draw ☉, ○, △
and ▽ with `GlyphView` from `BogenzeitUI`; text that cannot, such as the Inline complication and the
curved corners, carries the Unicode characters (spec §3.1). No hours or minutes in a Bogenzeit
readout; the clock watchOS draws in the corner is Apple's. Calendar data and the location stay on the
device; no network. Don't commit, push or publish to any store unless David asks.
