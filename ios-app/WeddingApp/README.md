# WeddingApp iOS

WeddingApp is a SwiftUI iOS client for managing wedding planning workflows. It connects to a Laravel API, supports email, Google, and Apple authentication, stores session tokens in the iOS Keychain, and provides localized Indonesian and English app content.

## Features

- Email registration and login with secure token persistence.
- Google Sign-In and Sign in with Apple social authentication.
- Dashboard with wedding summary, countdown, preparation progress, quotes, and quick actions.
- Checklist, guest, budget, vendor, inspiration, message, and account management screens.
- Push notification registration and backend device-token sync.
- Indonesian-first localization with optional English support.
- Custom app styling using bundled Cormorant Garamond and Poppins fonts.

## Requirements

- Xcode with iOS SDK support.
- An iOS simulator or physical iOS device.
- Access to the WeddingApp Laravel backend.
- A configured Google OAuth client if Google Sign-In is enabled.
- Apple Developer capabilities for Sign in with Apple and push notifications when testing those flows on device.

## Project Structure

```text
WeddingApp/Sources/App                  App entry point, theme, root view, localization, formatting
WeddingApp/Sources/Features/Auth        Login, registration, Apple and Google sign-in, session state
WeddingApp/Sources/Features/Dashboard   Main tab shell and home dashboard
WeddingApp/Sources/Features/Budget      Budget overview, expense, allocation, and payment flows
WeddingApp/Sources/Features/Checklist   Preparation checklist screens
WeddingApp/Sources/Features/Guests      Guest management UI
WeddingApp/Sources/Features/More        Profile, settings, privacy, help, wedding details, documents
WeddingApp/Sources/Features/Vendor      Vendor listing, detail, packages, and saved vendor views
WeddingApp/Sources/Models               API response models and local shared stores
WeddingApp/Sources/Networking           API client, API URL resolution, errors, Keychain storage
WeddingApp/Sources/Resources            Assets, privacy manifest, bundled fonts
WeddingApp/Sources/Services             Push notification coordination
```

## Dependencies

The app uses Swift Package dependencies for Google authentication and related networking/auth support:

- `GoogleSignIn`
- `GTMSessionFetcher`
- `GTMAppAuth`
- `AppAuth`
- `GoogleUtilities`
- `Promises`
- `InteropForGoogle`
- `AppCheck`

Resolve packages through Xcode if they are not already available.

## API Configuration

API endpoints are configured in `WeddingApp/Sources/Networking/APIConfig.swift` and selected through `APIResolver` during app bootstrap.

Debug builds try local API URLs first, then fall back to production:

- Simulator: `http://127.0.0.1:8000/api/v1`
- Physical device: `http://192.168.1.3:8000/api/v1`
- Production fallback: `https://weddingapp.co.id/api/v1`

For local backend development, run the Laravel API so it is reachable by the simulator or device:

```sh
php artisan serve --host=0.0.0.0 --port=8000
```

If the Mac LAN IP changes, update `lanHost` in `APIConfig.swift` before testing on a physical device.

To force Debug builds to use production, set:

```swift
static var usesProductionAPI = true
```

## Authentication Setup

### Google Sign-In

`GoogleSignInService` reads `GIDClientID` from the app Info.plist. Google login is unavailable if the value is missing, empty, or still contains a placeholder.

Configure the iOS OAuth client ID and URL scheme in the Xcode target settings before testing Google Sign-In.

### Sign in with Apple

`AppleSignInService` uses `AuthenticationServices` and requests the user's full name and email. Enable the Sign in with Apple capability for the app target when testing or shipping this flow.

### Session Storage

Authenticated API tokens are stored in the Keychain through `KeychainStore` using `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`.

## Push Notifications

`PushNotificationManager` configures `UNUserNotificationCenter`, asks for notification authorization after authentication, registers with APNs, and syncs the device token to the backend at `device-tokens`.

Enable push notification capability and use a physical device for full APNs testing.

## Localization

Localization is managed by:

- `WeddingApp/Sources/App/Localization/LocalizationManager.swift`
- `WeddingApp/Sources/App/Localization/L10n.swift`
- `WeddingApp/Sources/App/Localization/Localizable.strings/en`
- `WeddingApp/Sources/App/Localization/Localizable.strings/id`

Indonesian is the default language. English is available when language selection is enabled through the app language feature flag/store.

## Running the App

1. Open the project in Xcode.
2. Select the `WeddingApp` scheme.
3. Select an iOS simulator or connected iPhone.
4. Confirm package dependencies are resolved.
5. Configure the backend API and sign-in values needed for the flow you are testing.
6. Build and run from Xcode.

The active development scheme is `WeddingApp`. The current Xcode run destination is an iPhone simulator.

## Testing and Verification

This repository currently exposes dependency test files through the project navigator, but no app-specific test files were found. Use Xcode's build action to verify compile health after app code changes.

Recommended checks:

- Build the `WeddingApp` scheme in Xcode.
- Launch on simulator and verify login, dashboard bootstrap, and API fallback behavior.
- Test Google Sign-In only after `GIDClientID` and URL schemes are configured.
- Test Apple Sign-In and push notifications with the required Apple capabilities enabled.

## Troubleshooting

### Local API is not reached from a physical device

Physical devices cannot use the Mac's `localhost`. Start Laravel with `--host=0.0.0.0`, confirm the Mac and iPhone are on the same network, and update `lanHost` in `APIConfig.swift` to the Mac's current LAN IP.

### The app keeps using an old API URL in Debug

`APIResolver` caches the last reachable base URL in `UserDefaults`. Use `APIResolver.invalidateAndResolve()` from a debug path if you need to clear and recalculate the selected API URL.

### Google Sign-In button is unavailable or login fails immediately

Confirm `GIDClientID` is present in Info.plist and is not a placeholder. Also confirm the reversed client ID URL scheme is configured for the target.

### Session restores fail after relaunch

Check that the backend `auth/me` endpoint is reachable and that the stored token is still valid. Failed restore attempts clear the local Keychain token.

## Privacy

The app includes `WeddingApp/Sources/Resources/PrivacyInfo.xcprivacy`. It currently declares UserDefaults access and no collected data types or tracking domains.
