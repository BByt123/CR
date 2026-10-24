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

### GitHub Pages

Push the `main` branch to `https://github.com/BByt123/CR`. The included `.github/workflows/deploy-pages.yml` runs the tests, builds the web site into `dist/`, and deploys it to GitHub Pages. In the repository settings, set **Pages → Build and deployment → Source** to **GitHub Actions**. After the workflow finishes, the game will be available at `https://bbyt123.github.io/CR/`.

For a phone or tablet, deploy the repository with GitHub Pages or open the Vite URL on the device. The game detects touch hardware automatically and shows large multi-touch steering, throttle, brake, drift, item, and pause controls. Both portrait and landscape layouts are supported; landscape gives the widest race view. The browser page also includes a web-app manifest so supported mobile browsers can add it to the home screen.

## Build and tests

```powershell
npm test
npm run build
```

`npm run build` writes the production web bundle to `dist/` for GitHub Pages. The APK command sets the Android build target and writes its offline bundle to `android/app/src/main/assets/game/`.
