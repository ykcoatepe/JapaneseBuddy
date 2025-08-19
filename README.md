# JapaneseBuddy

Private iPad app for kana and kanji practice with Apple Pencil and a spaced repetition system. Includes Japanese text-to-speech and works fully offline.

## Run
Open in Xcode, select an iPad simulator or device, and press **Run**.

### Schemes
- The project’s scheme is `JapaneseBuddyProj`. If Xcode or `xcodebuild` can’t see it, open Xcode → Product → Scheme → Manage Schemes… and check the box “Shared” for `JapaneseBuddyProj`. Sharing writes the scheme under `xcshareddata`, which makes it visible to tools and other machines.

### Run & Test
- Build (simulator): `make build`
- Tests (simulator): `make test`
- List devices: `make devices` (shows names and UDIDs)
- Build for device: `make build-device UDID=<your-device-udid>`
- Test on device: `make test-device UDID=<your-device-udid>`

Notes:
- Device builds require a trusted, connected iPad with Developer Mode enabled and valid signing (Automatic signing recommended in Xcode). The CLI targets add `-allowProvisioningUpdates` to assist with automatic provisioning.
- These commands only build/test; installing and running the app on a physical device is best done from Xcode (toolbar Run) unless you use additional tooling like ios-deploy.

## Privacy
All data stays on the device. No analytics or third-party SDKs.

## License
MIT — see [LICENSE](LICENSE).

## Goals & Reminders
Set daily targets for new and review cards and track progress on the Home screen. Configure goals and optional local reminders in Settings; notifications stay on-device and are fully optional.
