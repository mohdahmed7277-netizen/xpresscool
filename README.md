# MyShop Inventory

A small-business app for **Inventory + Sales + Invoicing + QR Codes**, in **English and Arabic**. Works fully offline — all data stays on the device.

---

## 🚀 The Easy Way: Get Your APK / EXE / Mac App Without Installing Anything

You don't need Flutter, Android Studio, or any developer tools on your computer. GitHub will build all three apps for you automatically, for free.

### Step 1 — Create a free GitHub account
Go to https://github.com/signup (skip if you already have one).

### Step 2 — Create a new repository
1. Click the **+** icon (top right) → **New repository**
2. Name it anything, e.g. `myshop-app`
3. Leave it set to **Public** (or Private, both work)
4. Click **Create repository**

### Step 3 — Upload this project
1. On your new repo's page, click **uploading an existing file**
2. Drag in **every file and folder** from this project (unzip it first)
3. Scroll down, click **Commit changes**

### Step 4 — Let it build
1. Click the **Actions** tab at the top of your repo
2. You'll see "Build MyShop Apps" running automatically (takes about 5-10 minutes)
3. Once it shows a green checkmark ✅, click into that run

### Step 5 — Download your 3 files
At the bottom of that page, under **Artifacts**, you'll see:
- **myshop-android-apk** → unzip it, this is your installable Android app
- **myshop-windows-exe** → unzip it, run `myshop_inventory.exe` inside
- **myshop-macos-app** → unzip it, this is your Mac `.app`

That's it — three real, working apps, with zero installs on your end.

> If the Actions tab shows a red ❌ instead, click into it and copy the error text to me — I'll fix the code.

---

## 🛠 The Manual Way (if you prefer building locally)

1. Install Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Install Android Studio (for Android builds): https://developer.android.com/studio
3. Open a terminal in this folder and run:
   ```
   flutter create .
   flutter pub get
   flutter run
   ```
4. To build final files:
   ```
   flutter build apk --release          (Android)
   flutter build windows --release      (Windows — must run ON Windows)
   flutter build macos --release        (Mac — must run ON a Mac)
   ```

**Why 3 separate machines?** Apple only allows Mac apps to be compiled on a Mac, and Windows desktop apps need Windows-specific build tools. This isn't a Flutter limitation — it's true for every app development tool. The GitHub Actions method above solves this by using GitHub's own Windows, Mac, and Linux servers to do each build for you.

---

## Features
- **Two Languages**: Tap **AR/EN** in the top-right corner of the app to switch between English and Arabic (full right-to-left layout support)
- **Staff Login**: PIN-based login. First launch creates the owner/admin account; admins can add staff (cashier) accounts
- **Inventory**: add/edit/delete products, track stock, low-stock warnings
- **QR Codes**: every product gets a unique QR code (printable) for instant lookup
- **Existing Barcodes**: scan and save a product's existing manufacturer barcode too — checkout recognizes both
- **Point of Sale**: scan a product's QR/barcode (or pick manually) to build a cart, apply discount/tax
- **Invoices**: auto-generates a PDF invoice per sale, shareable/printable
- **Sales History**: browse past sales, revenue totals, export to CSV (opens in Excel)

## Project Structure
```
lib/
  models/       Product, Sale, Staff data classes
  db/           SQLite database helper (all offline storage)
  services/     Cart, login/session, language, PDF & CSV export
  l10n/         English + Arabic text
  screens/      All app screens
  main.dart     App entry point
.github/workflows/build.yml   Auto-builds APK/EXE/Mac app on GitHub
```

## Customizing
- Business name on invoices: edit `businessName` in `lib/screens/invoice_preview_screen.dart`
- App color: edit `colorSchemeSeed` in `lib/main.dart`
- Add more translated text: edit `lib/l10n/app_strings.dart`

## Camera Permission (needed for QR scanning — only relevant for local builds)
If you build locally rather than via GitHub Actions, run `flutter create .` first (it generates the `android/` and `ios/` folders), then:

**Android** — in `android/app/src/main/AndroidManifest.xml`, inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

**iOS** — in `ios/Runner/Info.plist`, inside the outer `<dict>`:
```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is needed to scan product QR codes.</string>
```
(The GitHub Actions workflow handles Android automatically; iOS builds aren't included since publishing to the App Store needs an Apple Developer account regardless.)
