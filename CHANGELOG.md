# Changelog

## v1.4

- Label correction only, no audio change. The chain at `0xAD00000F` is `DEVICEPP_TX_VOICE_FLUENCE_NN`, the neural network chain, not SMECNS. The classic single mic voice call chain is `0xAD000008`. The audio path is byte for byte the v1.3 audio path.
- `module.prop` description and the in-file comment in `usecaseKvManager.xml` now name the chain correctly.
- Documents the chain table in the README, including the untested `0xAD000008` SMECNS and `0xAD00001C` dual mic NN variants.

## v1.3

- Speakerphone calls now drive both WSA amps. `voice-speaker` and `voice-speaker-protected` route to `speaker` instead of `speaker-mono`, `voice-speaker-protected` gains the `WSA_SPKR_VI_2` mixer control, and `voice-speaker-protected-vbat` enables the second amp's VBAT line.
- Module name, description, version and update manifest move to v1.3.
- The mixer config is now byte identical to the build running on the test device, sha256 `abdf541fc6130c1c25eeeda0a61dd3100880d80807b6a0d4105cb30db576dea4`.
- Untracked an editor lock file that had been committed by mistake.

## v1.2

- Documented the tested build: OSOM Android 14, incremental 165 (`UKQ1.240227.165`).
- Documented that the +6 dB is empirical, chosen by ear on one unit.
- Documented the full scope of the gain change: video recording inherits it via `camcorder-mic`, VoIP likely does, `handset-mic-unprocessed` does not.
- Explained why `resourcemanager_waipio_ingot.xml` is in the module (unmodified stock, same incremental, changes nothing).
- Moved the Saga versus Seeker context to the bottom and cut the marketing line.
- Reframed OTA behavior as firmware support being over: OSOM ceased operations in September 2024 and Solana Mobile ended Saga support in October 2025, so the whole-file replacement has no future firmware left to mask. Custom vendor images are the only remaining caveat.
- Added `update.json` so Magisk reports updates.
- Added MIT license for packaging, docs, and build script, plus NOTICE for the BSD licensed vendor files.
- The built zip is no longer committed; releases carry the versioned asset.

## v1.1

- Earpiece calls: dual mic Fluence endfire (`0xAD000009`) to single mic SMECNS (`0xAD00000F`).
- `TX_DEC2 Volume` 84 to 90 (+6 dB) on `handset-mic` and `speaker-mic`.
