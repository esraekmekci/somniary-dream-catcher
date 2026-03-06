# Somniary - Dream Catcher

Somniary is a Flutter + Firebase dream journal app with an AI interpreter.
Users can write (or transcribe) dreams, get a calm symbolic/psychological interpretation, and build a personal timeline of dreams.

## What It Does (Current State)

- Email/password authentication.
- Profile memory context (age range, gender, relationship status, occupation, stress level, sleep pattern, zodiac sign).
- Chat-based dream interpretation with a safe, non-deterministic tone.
- Language-aware output (English/Turkish).
- Automatic dream metadata generation:
  - `autoTitle` (short generated dream title)
  - `primaryMood` (Curious, Calm, Anxious, Peaceful)
  - `symbols[]` and `themes[]`
- Daily free quota system:
  - Free users: 1 interpretation/day
  - Premium users: unlimited + voice transcription
- Dream Journal timeline + detailed dream page.
- Dark/light theme support with a calm visual style.

## Tech Stack

- Flutter (Material 3)
- Firebase Auth, Firestore, Cloud Functions, Storage
- Mistral API (text + transcription via backend functions)

## API Endpoints (Cloud Functions)

- `POST /interpretDream`
  - Input: `uid`, `dreamText`, `source`, `chatId?`
  - Output: interpretation + extracted metadata + saved dream/chat ids
- `POST /transcribeAudio` (premium)
  - Input: `uid`, `audioBase64?`, `storagePath?`
  - Output: transcribed text

## Developer Setup

For full local setup, Firebase configuration, deployment, and troubleshooting:

See [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md).
