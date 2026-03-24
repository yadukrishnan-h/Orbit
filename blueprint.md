# Orbit: Application Blueprint & Architecture

## 1. Project Overview

Orbit is a mobile-first, offline-first SSH and SFTP server management application built with Flutter. It establishes persistent, direct peer-to-peer connections to remote servers to continuously poll health metrics (CPU, RAM, Disk, Latency) and manage files, all without routing traffic through a centralized developer proxy.

## 2. Core Architecture & Tech Stack

- **Framework:** Flutter (Android 15 Ready, 16KB page alignment support).
- **State Management:** `flutter_riverpod` (v2.x). Strict use of immutable state and `Provider`/`StateNotifierProvider` for separating business logic from the UI.
- **Routing:** `go_router` for declarative navigation and deep-linking capabilities.
- **Database (Storage):** `hive` (NoSQL) for high-performance, synchronous local storage of server metadata and historical metric logs. Entirely encrypted at rest via **AES-256** (via `HiveAesCipher`).
- **Remote Protocol:** `dartssh2` handles all SSH terminal executions, SFTP file browsing, and background telemetry polling.
- **Concurrency:** Heavy metric parsing and SSH stream handling are offloaded to background **Isolates** to ensure the main UI thread remains 60/120fps smooth.

## 3. Security Architecture (Strictly Enforced)

Orbit operates on a **Zero-Knowledge** architecture.

- **Encryption at Rest:** All sensitive data (SSH keys, Master PINs, Passphrases) is encrypted using AES-256 via the `flutter_secure_storage` package, backed by the Android Keystore / iOS Keychain.
- **Authentication Lockout:** The app features a 3-phase PIN lockout system to prevent brute-force attacks.
- **Biometrics:** `local_auth` is utilized to gate access to the app natively; biometric data never leaves the OS.
- **No Telemetry:** The app explicitly omits third-party analytics trackers to preserve infrastructure privacy.

## 4. UI/UX Design System

Orbit utilizes a custom, dark-first "Premium System" aesthetic. Any new features must adhere to these visual guidelines:

- **The `SystemCard` Aesthetic:** Dashboard widgets, lists, and settings tiles are wrapped in a custom container with subtle borders, a deep dark grey background, and soft drop shadows to create a "lifted" hierarchy.
- **Typography:** \* UI Text: Clean, modern sans-serif (e.g., Roboto/Inter via `textTheme`).
  - Terminal & Logs: Monospace only. `GoogleFonts.firaCode` is strictly used for any raw server output, paths, or code blocks.
- **Iconography:** The `lucide_icons` package is the standard for all UI icons.
- **Feedback:** All asynchronous actions (SSH connections, file uploads, Play Store update checks) must display a `CircularProgressIndicator` and resolve with a clear `SnackBar` message.

## 5. Current Feature Set (v1.1.0+)

- **Dashboard:** Fleet overview, real-time polling charts (CPU/RAM/Network).
- **Terminal:** Full SSH interactive terminal with batched output processing.
- **SFTP Browser:** Remote file management (list/grid views, upload/download, delete).
- **Settings:** Biometric toggles, PIN management, dynamic Play Store update checking (`in_app_update`), and native in-app Markdown rendering for legal documents.

## 6. Current Development Plan
