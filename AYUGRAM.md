# AyuGram for iOS

An unofficial Telegram client built on [Telegram-iOS](https://github.com/TelegramMessenger/Telegram-iOS),
porting features from [AyuGram](https://github.com/AyuGram).

## Features

**Ghost Mode** (Settings → Ghost Mode):

| Switch | What it does |
|---|---|
| Don't Read Messages | Read receipts are not sent. Chats still look read on this device. |
| Don't Read Stories | Story authors are not told you viewed their stories. |
| Don't Send Online | The account is always reported as offline. |
| Don't Send Typing | "typing…", "recording…" and similar statuses are not sent. |

Code: `submodules/TelegramCore/Sources/Ayu/`, `submodules/SettingsUI/Sources/Ayu/`.

## Building without a Mac

The `Build unsigned IPA` GitHub Actions workflow builds an unsigned IPA on a macOS runner.

1. Add the repository secrets `TELEGRAM_API_ID` and `TELEGRAM_API_HASH`
   (from https://my.telegram.org/apps) under Settings → Secrets and variables → Actions.
   Without them the build uses the official Telegram iOS key from
   `build-system/appstore-configuration.json`, which Telegram's API terms do not allow for
   third-party clients; replace it with your own key when you can.
2. Run the workflow from the Actions tab (Run workflow).
3. Download the IPA from the run's artifacts.
4. Install it with [Sideloadly](https://sideloadly.io) or [AltStore](https://altstore.io).
   With a free Apple ID the signature lasts 7 days; Sideloadly can strip the app extensions
   if you run out of App IDs.

macOS runner minutes are free for public repositories. On a private repository they count
10× against the monthly quota.
