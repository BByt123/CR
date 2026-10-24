# Turbo Kart Rally

Turbo Kart Rally is a single-player 3D kart racer built with Three.js. Race seven AI drivers around Palm Cove Circuit, drift through corners, and use items to overtake. Local network and online multiplayer have been removed.

## Android

The Samsung-friendly Android app runs fullscreen on phones and tablets in either orientation, uses touch steering and action buttons, bundles the game for offline play, and requires Android 8.0 or newer. Landscape is recommended for the widest race view, while portrait mode remains playable with an adapted HUD and control layout.

1. Install Node.js 20 or later, Android Studio, Android SDK Platform 35, and Android SDK Build-Tools.
2. Double-click `build-apk.cmd`, or open PowerShell in this folder and run `npm.cmd run apk`. The first run installs the local game dependencies. These launchers allow this build script to run without changing your saved PowerShell execution policy.
3. Transfer `apk/Turbo-Kart-Rally-Samsung.apk` to the phone, open it, and allow installation from that source when Android asks.

The APK uses a local debug signing key, so Android may ask the user to trust the APK source. For Play Store publishing, configure a private release signing key.

## Run in a browser

Install Node.js 20 or later, then run:

```powershell
npm install
npm run dev
```

Open the local URL printed by Vite. Use WASD or the arrow keys, Space to drift, E to use an item, and Escape to pause. Use a gamepad or touch screen as well.

## Build and tests

```powershell
npm test
npm run build
```

The production game bundle is written to `android/app/src/main/assets/game/` so Android can package it for offline use.
