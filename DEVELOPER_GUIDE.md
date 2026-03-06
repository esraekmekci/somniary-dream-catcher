# Somniary Developer Guide

This guide is for contributors who want to run, debug, and extend Somniary from scratch.

## 1. Prerequisites

Install these first:

- Flutter SDK (stable channel)
- Dart (comes with Flutter)
- Android Studio (or VS Code + Android toolchain)
- Xcode (for iOS builds on macOS, optional)
- Node.js 20.x
- npm
- Firebase CLI
- FlutterFire CLI

Verify:

```bash
flutter doctor
node -v
npm -v
firebase --version
dart pub global activate flutterfire_cli
flutterfire --version
```

## 2. Clone and Install Dependencies

From project root:

```bash
flutter pub get
cd functions
npm install
cd ..
```

## 3. Firebase Project Setup

Create or use an existing Firebase project (example used in this repo: `somniary-dream-catcher`).

Enable these services:

- Authentication: Email/Password
- Firestore Database
- Cloud Functions
- Storage (for voice files)

## 4. FlutterFire Configuration

Generate Firebase config for your app:

```bash
flutterfire configure
```

Important notes:

- This repository is currently configured for Android.
- If you need iOS, rerun `flutterfire configure` and include iOS.
- After configure, make sure these files exist and are up to date:
  - `lib/firebase_options.dart`
  - `android/app/google-services.json`

## 5. Firestore Rules and Indexes

Deploy security rules and indexes:

```bash
firebase deploy --only firestore:rules,firestore:indexes --project <your-project-id>
```

Current `firestore.indexes.json` is intentionally minimal:

- `"indexes": []`
- `"fieldOverrides": []`

If you see an index error like "index is not necessary", keep indexes empty unless a query explicitly requires a composite index.

## 6. Functions Secrets and Models (Mistral)

Set the Mistral API key:

```bash
firebase functions:secrets:set MISTRAL_API_KEY
```

Optional runtime model environment variables (already have defaults in code):

- `MISTRAL_MODEL_FREE` (default: `mistral-small-latest`)
- `MISTRAL_MODEL_PREMIUM` (default: `mistral-small-latest`)
- `MISTRAL_MODEL_STT` (default: `voxtral-mini-latest`)

Local reference values live in:

- `functions/.env.example`

## 7. Deploy Cloud Functions

Deploy only functions:

```bash
firebase deploy --only functions --project <your-project-id>
```

Current HTTP functions:

- `interpretDream`
- `transcribeAudio`

## 8. Run the App Locally

Start on connected device/emulator:

```bash
flutter run
```

Use `hot reload` for UI and `hot restart` when state/init logic changes.

## 9. Core Data Model

Main collections:

- `users/{uid}`
  - `isPremium`, daily quota fields, `profile`, `aiSummary`
- `users/{uid}/dreams/{dreamId}`
  - `dreamText`, `autoTitle`, `primaryMood`, `languageCode`, `interpretation`
- `users/{uid}/chats/{chatId}/messages/{messageId}`
  - `role`, `text`, `createdAt`, `linkedDreamId`

## 10. Premium and Quota Logic

- Free users: max 1 interpretation/day (`freeQuotaDate`, `freeQuotaUsed`)
- Premium users: quota bypass + voice transcription endpoint access
- Premium is currently controlled by backend `isPremium` flag in user document

## 11. Language-Aware Behavior

`interpretDream` detects input language and keeps:

- Interpretation language
- Generated dream title language
- Extracted symbol/theme language

The saved `languageCode` is stored on each dream document.

## 12. Troubleshooting

### Auth works but Firestore read/write fails (`permission-denied`)

Cause:

- Firestore rules are too strict or not deployed.

Fix:

```bash
firebase deploy --only firestore:rules --project <your-project-id>
```

Also ensure requests are under `users/{uid}` for the signed-in user.

### `flutterfire configure` issues on Android

If CLI behaves unexpectedly:

- Re-run from project root.
- Ensure Android package name is valid in `android/app/build.gradle*`.
- Check generated `google-services.json` path.

### Function returns 404 / URL not found

Cause:

- Function not deployed to current Firebase project, or wrong region URL.

Fix:

- Deploy again with explicit project id.
- Confirm function names in Firebase console.

### Mistral model errors

Cause:

- Selected model unavailable for your account.

Fix:

- Change model env var to an available Mistral model.
- Redeploy functions after updating env/secrets.

## 13. Recommended Contributor Workflow

1. Pull latest changes.
2. Run `flutter pub get` and `npm install` (inside `functions`) if dependencies changed.
3. Run quick checks:
   - `flutter analyze`
   - `flutter test` (if tests exist for touched area)
4. Test login, chat send, journal list/detail manually.
5. If backend changed, deploy functions before QA.

## 14. File Map (High Value)

- `lib/screens/` -> UI screens
- `lib/state/app_state.dart` -> app-level state/actions
- `lib/services/` -> Firestore/functions wrappers
- `lib/models/` -> data models
- `functions/src/index.js` -> backend endpoints and AI orchestration
- `firestore.rules` -> access control
- `firebase.json` -> Firebase config

## 15. Security Notes

- Never place Mistral API keys in Flutter client code.
- Keep all AI API calls in Cloud Functions.
- Respect per-user document boundaries in Firestore rules.

