# Security Policy

## Reporting a vulnerability

Please report suspected vulnerabilities privately, using the **Report a vulnerability** button on the Security tab of this repository. If that button is not there, or you would rather not go through GitHub, email david.anderson@excelano.com instead. I aim to respond within seven days.

Please do not open public issues for security problems.

## Supported versions

The latest release receives security fixes. Older versions are not supported. A fix ships in a new App Store release.

## What Bogentag can access

Bogentag makes no network request, opens no socket and links no networking or analytics code. The Apple Watch app, the widgets and the complications are the same; the watch works without the iPhone.

With permission, the iPhone and iPad app reads the device's calendars through EventKit while it is on screen, and keeps no copy of an event. It creates an event only when you set a moment, and changes or deletes one only when you save or delete it in its details or in the system's event editor. The watch app does not read calendars.

Each app reads location only with its own permission and only while it is on screen. Withdrawing the permission discards the stored coordinates.

Starting a timer asks to send notifications, used only to say the timer has ended. On the iPhone a running timer is also shown as a Live Activity, updated on the device and never by push.

## What Bogentag stores

Each app keeps the coordinates in use and the dial's scale in a container it shares only with its own widgets or complications. Its own preferences hold the display settings, the timer and stopwatch and, on the iPhone and iPad, whether the tour has been seen and the identifiers of hidden calendars, all on the device. Removing the app removes them.
