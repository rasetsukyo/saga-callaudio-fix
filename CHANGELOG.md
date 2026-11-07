# Changelog

## v1.2

- Documented the tested build: OSOM Android 14, incremental 165 (`UKQ1.240227.165`).
- Documented that the +6 dB is empirical, chosen by ear on one unit.
- Documented the full scope of the gain change: video recording inherits it via `camcorder-mic`, VoIP likely does, `handset-mic-unprocessed` does not.
- Explained why `resourcemanager_waipio_ingot.xml` is in the module (unmodified stock, same incremental, changes nothing).
- Moved the Saga versus Seeker context to the bottom and cut the marketing line.
- Added `update.json` so Magisk reports updates.
- Added MIT license for packaging, docs, and build script, plus NOTICE for the BSD licensed vendor files.
- The built zip is no longer committed; releases carry the versioned asset.

## v1.1

- Earpiece calls: dual mic Fluence endfire (`0xAD000009`) to single mic SMECNS (`0xAD00000F`).
- `TX_DEC2 Volume` 84 to 90 (+6 dB) on `handset-mic` and `speaker-mic`.
