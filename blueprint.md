# Orbit: Application Blueprint & Architecture

## 1. Project Overview

Orbit is a mobile-first, offline-first SSH and SFTP server management application built with Flutter. It establishes persistent, direct peer-to-peer connections to remote servers to continuously poll health metrics (CPU, RAM, Disk, Latency) and manage files, all without routing traffic through a centralized developer proxy.

## 2. Core Architecture & Tech Stack

- **Framework:** Flutter (Android 15 Ready, 16KB page alignment support).
- **State Management:** `flutter_riverpod` (v3.x). Strict use of immutable state and `Provider`/`NotifierProvider` for separating business logic from the UI.
- **Routing:** `go_router` for declarative navigation and deep-linking capabilities.
- **Database (Storage):** `hive` (NoSQL) for high-performance, synchronous local storage of server metadata and historical metric logs. Entirely encrypted at rest via **AES-256** (via `HiveAesCipher`).
- **Remote Protocol:** `dartssh2` handles all SSH terminal executions, SFTP file browsing, and background telemetry polling.
- **Concurrency:** Heavy metric parsing and SSH stream handling are offloaded to background **Isolates** to ensure the main UI thread remains 60/120fps smooth.

## 3. Security Architecture (Strictly Enforced)

Orbit operates on a **Zero-Knowledge** architecture.

- **Encryption at Rest:** All sensitive data (SSH keys, Master PINs, Passphrases) is encrypted using AES-256 via the `flutter_secure_storage` package, backed by the Android Keystore / iOS Keychain.
- **Authentication Lockout:** The app features a progressive Master PIN lockout system with monotonic in-memory timer and anti-tamper clock-manipulation protection.
- **Biometrics:** `local_auth` is utilized to gate access to the app natively with a mandatory two-way authentication gate (required to enable and disable); biometric data never leaves the OS.
- **Host Key Verification:** Interactive TOFU (Trust-On-First-Use) dialog with OpenSSH SHA-256 / hex fingerprint display and MITM protection.
- **No Telemetry:** The app explicitly omits third-party analytics trackers to preserve infrastructure privacy.

## 4. UI/UX Design System

Orbit utilizes a custom, dark-first "Premium System" aesthetic. Any new features must adhere to these visual guidelines:

- **The `SystemCard` Aesthetic:** Dashboard widgets, lists, and settings tiles are wrapped in a custom container with subtle borders, a deep dark grey background, and soft drop shadows to create a "lifted" hierarchy.
- **Typography:**
  - UI Text: Clean, modern sans-serif (e.g., Roboto/Inter via `textTheme`).
  - Terminal & Logs: Monospace only. `GoogleFonts.firaCode` is strictly used for any raw server output, paths, or code blocks.
- **Iconography:** The `lucide_icons_flutter` package is the standard for all UI icons.
- **Feedback:** All asynchronous actions (SSH connections, file uploads, Play Store update checks) must display a `CircularProgressIndicator` and resolve with a clear `SnackBar` message.

## 5. Current Feature Set (v1.2.0)

- **Dashboard:** Fleet overview, real-time polling charts (CPU, RAM, Disk, Latency, Swap, Uptime), dynamic scaling `CpuLineChart`, radial `DiskUsageGauge`, and quick server management actions (Duplicate, Remote Reboot, Remote Power Off).
- **Terminal:** Full SSH interactive terminal with batched output processing, sticky Ctrl/Alt modifier toolbar, native clipboard paste, and multi-byte UTF-8 streaming resilience.
- **SFTP Browser:** Remote file management (list/grid views, search filtering, upload/download, rename, permission inspection, directory creation, delete), chunked streaming transfers (OOM safe), and Android 11+ scoped storage.
- **Settings:** Biometric toggles, Master PIN management with anti-tamper lockout, optional server geolocation toggle, polling interval selection, app icon picker, language selection, legal document viewer, and Google Play Store update checking.
