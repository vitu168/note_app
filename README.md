# note_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## iOS: Code signing (run on device)
If you get an error like "No valid code signing certificates were found" or
"No development certificates available to code sign app for device deployment":

1. Open the workspace (CocoaPods workspace) in Xcode:
   - cd to project root and run:
     - `open ios/Runner.xcworkspace`
   - In Xcode, select the **Runner** project → **Targets** → **Runner** → **Signing & Capabilities**.
2. Sign in to your Apple account (Xcode → Preferences → Accounts) and select your **Team**.
3. Enable **Automatically manage signing** and let Xcode create a Development Certificate & Provisioning Profile.
4. If you prefer to set signing from the repo (local): run the helper to set your Team ID in the Xcode project:
   - `./scripts/ios/set_development_team.sh YOUR_TEAM_ID` (this inserts your Team ID into the Xcode project file; it creates a `.bak` backup first).
5. Connect your iOS device and run from Xcode or Flutter:
   - `flutter run -d <your-device-id>`

Notes:
- For simulator builds you do not need code signing.
- If you want CI/secure signing, consider setting up Fastlane Match or a secure signing workflow.

If you'd like, I can set the Bundle ID in the project to a custom value (you still must choose your Team in Xcode). Let me know the Bundle ID you want and I'll update the project files for you.

