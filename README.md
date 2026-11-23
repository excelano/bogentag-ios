# Bogentag

Bogentag shows the day in Bogenzeit: time read as position on the Sun's arc, in
spans from solar noon (☉) or solar midnight (○), with sunrise (△) and sunset (▽)
between. The standard, its reference implementation and its test vectors live at
https://github.com/excelano/bogenzeit.

On iPhone and iPad it opens on a calendar of the calendars already on the device,
read through EventKit. A day runs from one ○ to the next and every span has the same
height, so sunrise, noon and sunset sit at fixed places and the events move with the
season. On iPad, as many days as fit sit side by side and share one gutter of span
marks. Pressing and holding the day reads any moment on it, and holding still sets
that moment as a zero-length event with an alert. An event's start and end can be
set in Bogenzeit from its details, and the system's event editor, opened from there,
changes the rest or deletes it.

The current reading in the calendar's toolbar opens the dial: the sky with the Sun on
its ring and its position in the center, in spans or kiloseconds, with a timer and a
stopwatch that count in both and a tour that explains the system. On Apple Watch the
dial is the main screen, and complications and widgets put the reading on watch faces,
the Home Screen and the Lock Screen. Everything is computed on the device; the app
uses no network.

`docs/concept.md` describes the calendar and `docs/bogentag-spec.md` the dial. On the
Linux desktop the same two halves are separate apps,
[bogentag-calendar](https://github.com/excelano/bogentag-calendar) and
[bogentag-dial](https://github.com/excelano/bogentag-dial).

## What is here

The engine and the drawn glyphs come from
https://github.com/excelano/bogenzeit-swift. `Bogentag.xcodeproj` builds the iPhone
and iPad app from `Bogentag/` and `Shared/`, the watch app from `Bogentag Watch App/`
and `Shared/`, and the widget extensions from `BogentagPhoneWidgets/` and
`BogentagWidgets/`. `packaging/` holds the store listing, the release notes, the
privacy entry and the screenshot recipe the release apps read.

## Building

The app builds with Xcode from the project at the root, which fetches the engine
package on first build; the iPhone scheme embeds the watch app. A Debug build launched
with `--demo` shows a made-up week in Houston in place of the device's calendars and
location; `Bogentag/CalendarDemo.swift` and `Shared/Support/Demo.swift` read the other
launch arguments.

> [!WARNING]
> Do NOT submit Bogentag, or a copy of it under another name, to the App Store. Apple's
> App Review Guideline 4.3 treats copies of other apps as spam, and a 4.3
> finding can flag the developer account that submitted it, so that every app
> the account sends afterwards is flagged too. Build it for your own devices and keep
> it there.

## License

MIT. See [LICENSE](LICENSE).
