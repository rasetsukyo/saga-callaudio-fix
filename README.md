# Saga Call Audio Fix

Systemless Magisk module for the Solana Saga (gen 1). It fixes robotic, muffled, and distorted outgoing voice during earpiece calls on stock firmware.

The microphone hardware is fine. Playback is fine. The problem is the vendor audio configuration: voice calls are routed through a dual mic Qualcomm Fluence endfire graph that does not calibrate correctly on the post OTA vendor image. This module routes normal earpiece calls through the single mic Fluence SMECNS graph instead, and lifts the transmit gain by 6 dB to make up for the level the second mic path was contributing.

## Where the Saga sits: flagship versus mass market

Think Model S and Model 3. Both are Teslas, both are electric, and both exist to push the same idea forward. One is the flagship that proves the idea at any price, the other is the mass market car that puts it in far more driveways. That is the Saga and the Seeker.

The Saga (2023) is the Model S of the pair. Ceramic back, 6.67 inch 120 Hz OLED, Snapdragon 8+ Gen 1, 12 GB RAM, 512 GB storage, 50 MP main plus 12 MP ultrawide, 4110 mAh, and a $1,000 launch price. Premium materials, premium silicon, the best of everything OSOM and Solana Mobile could put in a phone at the time. It was a statement device.

The Seeker (2025) is the Model 3. 6.36 inch 2670x1200 120 Hz AMOLED, MediaTek Dimensity 7300, 8 GB RAM, 128 GB storage, 108 MP main, plastic frame, 4500 mAh, and $500 ($450 at preorder). It is not trying to out spec the Saga. It is trying to get Seed Vault into many more hands at a price that makes saying yes easy.

| | Saga (Model S energy) | Seeker (Model 3 energy) |
| --- | --- | --- |
| Year | 2023 | 2025 |
| Price | $1,000 | $500 |
| SoC | Snapdragon 8+ Gen 1 | MediaTek Dimensity 7300 |
| Memory | 12 GB / 512 GB | 8 GB / 128 GB |
| Display | 6.67 in OLED, 120 Hz | 6.36 in AMOLED, 120 Hz |
| Body | Ceramic back | Plastic frame |
| Cameras | 50 MP + 12 MP | 108 MP + 50 MP + 13 MP, 32 MP front |
| Battery | 4110 mAh | 4500 mAh |
| Seed Vault | Yes | Yes |

What they share is the point. Both ship Seed Vault. Both are built for people who would rather hold their own keys than trust an exchange, and both push mobile crypto past the "install an app and hope" era the way EVs pushed past gas cars. Different tier, same thesis, same crowd: forward thinkers who want the thing to actually exist rather than wait for it.

### Why this module is Saga only

The Seeker runs a MediaTek Dimensity 7300 with an entirely different vendor audio stack, so none of the files in this module exist on it. This fix targets the Qualcomm `sku_taro` config on the Saga gen 1, which is where the earpiece call routing actually lives. The Saga versus Seeker comparison is about tier, materials, and silicon. It has nothing to do with the mic bug. The mic bug is a vendor graph mapping problem on the Saga's post OTA image, and it would be a mapping problem on a $1,000 phone or a $300 phone running the same config.

## What it changes

Two functional changes, both at the vendor audio config layer.

### 1. Voice call uplink: endfire to SMECNS

`system/vendor/etc/usecaseKvManager.xml`, device `PAL_DEVICE_IN_HANDSET_MIC`, stream `PAL_STREAM_VOICE_CALL`:

```xml
<!-- before: DEVICEPP_TX_VOICE_FLUENCE_ENDFIRE -->
<graph_kv key="0xAD000000" value="0xAD000009"/>
<!-- after: DEVICEPP_TX_VOICE_FLUENCE_SMECNS -->
<graph_kv key="0xAD000000" value="0xAD00000F"/>
```

The explicit `CustomConfig="dual-mic"` route still points at the endfire graph, so anything that asks for dual mic behavior keeps it. Only the default voice call route moves.

### 2. Transmit gain +6 dB

`system/vendor/etc/audio/sku_taro/mixer_paths_waipio_ingot.xml`, the `handset-mic` and `speaker-mic` paths:

```xml
<path name="handset-mic">
    <path name="dmic2" />
    <ctl name="TX_DEC2 Volume" value="90" />
</path>
```

The stock default for `TX_DEC2` in this config is 84. 90 is +6 dB on the QTI DEC volume scale, where 84 is the 0 dB reference and each step is 1 dB. Dropping the second microphone drops the level it was adding, so the gain brings the single mic path back up to a usable level.

## Files in the module

```
module.prop
system/vendor/etc/audio/sku_taro/mixer_paths_waipio_ingot.xml
system/vendor/etc/audio/sku_taro/resourcemanager_waipio_ingot.xml
system/vendor/etc/usecaseKvManager.xml
```

All three vendor files are replaced as a set at boot so the HAL sees a consistent `sku_taro` audio config.

## Requirements

- Solana Saga (gen 1) on stock OSOM firmware. Do not flash this on a Seeker, and do not flash it on a custom ROM that does not use the `sku_taro` vendor audio config.
- Magisk 24 or newer. KernelSU is untested.
- Root shell over ADB if you install from Termux. The Magisk app works too.

## Install

### Magisk app

Download `saga-callaudio-fix.zip` from this repo, open Magisk, Modules, Install from storage, pick the zip, reboot.

### Termux + ADB, on the phone, no PC

```bash
pkg update && pkg install android-tools

# Developer options > Wireless debugging, pair once, then connect.
adb pair 127.0.0.1:PAIR_PORT
adb connect 127.0.0.1:CONNECT_PORT
adb devices

adb push ~/storage/downloads/saga-callaudio-fix.zip /sdcard/Download/
adb shell su -c 'magisk --install-module /sdcard/Download/saga-callaudio-fix.zip'
adb reboot
```

Make sure `su` is granted for Termux in Magisk before the install line. The reboot is not optional: the audio HAL reads these files at boot.

## Check that it applied

```bash
adb shell 'su -c "grep -c \"was ENDFIRE\" /vendor/etc/usecaseKvManager.xml"'
```

That should print 1, which means the SMECNS mapping is live.

```bash
adb shell 'su -c "grep -c \"Saga call-audio fix\" /vendor/etc/audio/sku_taro/mixer_paths_waipio_ingot.xml"'
```

That should print 2, which means both gain overrides are live.

Then place a real earpiece call. The test is the person on the other end, not you.

## Tuning the gain

The value is `TX_DEC2 Volume` in the mixer path. Stock is 84, this module uses 90 (+6 dB). If your unit sounds hot or quiet, try 87 (-3 dB) or 93 (+3 dB). Edit the value, rebuild the zip with `./build.sh`, reflash, reboot. One step is 1 dB.

Changing only `handset-mic` leaves loudspeaker calls alone, and the reverse.

## Rollback

Disable it in the Magisk app and reboot, or:

```bash
adb shell su -c 'touch /data/adb/modules/saga_callaudio_fix/disable'
adb reboot
```

Remove it completely:

```bash
adb shell su -c 'rm -rf /data/adb/modules/saga_callaudio_fix'
adb reboot
```

If the device will not boot, hold volume down while the boot animation is showing to enter Magisk safe mode, which disables modules. Then delete `/data/adb/modules/saga_callaudio_fix` and reboot.

## OTA behavior

The module lives systemless in `/data/adb/modules` and mounts over `/system/vendor` at boot, so a vendor OTA does not remove it and the overlay wins. If an OTA changes the vendor audio config in a way that matters, re-check the SMECNS mapping and the `TX_DEC2` value, then update the module.

## Notes

- Bluetooth and USB call audio are untouched.
- Loudspeaker calls also get the +6 dB, because `speaker-mic` uses the same `TX_DEC2` value.
- The files under `system/` are Qualcomm and OSOM vendor configs and carry the BSD terms in their headers. The module packaging and these docs are by [rasetsukyo](https://github.com/rasetsukyo).

## Build

```bash
./build.sh
```

That packs `module.prop` and `system/` into `saga-callaudio-fix.zip`.
