# Release signing

Nemro 0.1.0 builds a release APK signed with the debug key. That is fine for
testing, but a public release needs its own keystore:

- A debug-signed APK cannot be published to Google Play.
- Once users install a build signed with the real key, every later update must
  use the same key. If the key is lost, existing users cannot update — they
  must uninstall and reinstall, losing local data.
- A debug-signed install cannot be upgraded in place by a real-signed build
  (signature mismatch), so switch to the real key before distributing widely.

## 1. Create a keystore (once, on your own machine)

Use the JDK's `keytool` (it ships with Android Studio and Temurin JDK 17):

```sh
keytool -genkeypair -v \
  -keystore nemro-release.keystore \
  -alias nemro \
  -keyalg RSA -keysize 2048 -validity 10000
```

`keytool` asks for a keystore password and a key password. Choose strong ones
and store them somewhere safe (a password manager). Never share them, and
never commit the `.keystore` file — `.gitignore` excludes `*.keystore`,
`*.jks`, and `key.properties` for this reason.

Back the keystore up offline (for example, an encrypted USB drive). Losing it
means a new app identity.

## 2. Sign local release builds

Put the keystore in `android/app/` and create `android/key.properties`
(this file is gitignored — it must never be committed):

```properties
storePassword=<your keystore password>
keyPassword=<your key password>
keyAlias=nemro
storeFile=nemro-release.keystore
```

Then a normal release build signs with it:

```sh
flutter build apk --release
```

If `android/key.properties` is absent, the build falls back to the debug key,
so local development keeps working without any setup.

## 3. Sign CI builds (optional)

Until the secrets below exist, CI builds keep using the debug key. To switch
CI to the real key, add four repository secrets (repo → Settings → Secrets
and variables → Actions → New repository secret):

- `ANDROID_KEYSTORE_BASE64` — the base64 of the keystore file:

  ```sh
  base64 -w0 android/app/nemro-release.keystore
  ```

  (On macOS, use `base64 -b0` instead of `-w0`.)

- `ANDROID_KEY_ALIAS` — the key alias (for example, `nemro`).
- `ANDROID_KEY_PASSWORD` — the key password.
- `ANDROID_STORE_PASSWORD` — the keystore password.

The CI workflow decodes the keystore and writes `key.properties` inside the
ephemeral runner only; neither file is committed or kept after the run.

## Checklist before the first public release

- [ ] Keystore created and backed up offline.
- [ ] `android/key.properties` works for a local `flutter build apk --release`.
- [ ] The four CI secrets are set (if CI should produce the release APK).
- [ ] The release APK installs and reports the expected version.
