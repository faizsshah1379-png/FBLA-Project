# FBLA CONNECT SwiftUI

SwiftUI version of FBLA CONNECT with FBLA brand colors and chapter selection.

## What is included

- App name: FBLA CONNECT
- FBLA color palette (navy, blue, gold accents)
- Logo slot: `Image("FBLALogo")` in header
- Chapter selection on first launch + editable in Profile
- 6 tabs: Home, Profile, Timeline, Resources, News, Community
- Persistent custom reminders via `UserDefaults`

## Run in Xcode Simulator

1. Open Xcode.
2. Create a new iOS App project named `FBLA CONNECT` (SwiftUI + Swift).
3. In Finder, open `/Users/faizshah/Documents/Playground/PartyPilotSwiftUI`.
4. Drag all folders/files from `PartyPilotSwiftUI` into your Xcode project navigator.
5. When prompted, enable `Copy items if needed` and add to your app target.
6. Delete Xcode's default `ContentView.swift` / `App` files if duplicates exist.
7. Ensure `FBLAConnectApp.swift` is the only `@main` app entry.
8. Add your FBLA logo image to `Assets.xcassets` with the exact name `FBLALogo`.
9. Select an iPhone simulator (for example, iPhone 16).
10. Click Run (play button) or press `Cmd + R`.

