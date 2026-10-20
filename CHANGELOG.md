# Changelog

All notable changes to the Orbit project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.2.0] - Build 6 - 2026-10-18

### Security Hardening
- **Interactive TOFU Host Key Verification:** Replaced blind host key acceptance with an interactive Trust-On-First-Use confirmation dialog displaying key types and standardized OpenSSH `SHA256:<base64>` / colon-separated hex fingerprints. Aborts connection immediately upon key mismatch to protect against Man-in-the-Middle (MITM) attacks.
- **Monotonic Lockout Timer & Anti-Tamper Protection:** Re-architected Master PIN lockout countdown to use an in-memory monotonic stopwatch, eliminating frequent flash storage writes. Added system clock manipulation detection that immediately triggers a 5-minute penalty lockout if the device time is adjusted backward.
- **Two-Way Biometric Authentication Gate:** Secured the biometrics toggle in Settings to require biometric verification or Master PIN authentication before biometrics can be disabled, preventing unauthenticated security disarming.
- **15-Second Background Auto-Lock & Session Termination:** Implemented lifecycle-aware auto-lock using a monotonic background stopwatch. When Orbit remains in the background for 15 seconds or longer, the app automatically locks and immediately terminates active SSH and SFTP socket sessions to prevent session hijacking.
- **Android Screen & Snapshot Shield (`FLAG_SECURE`):** Enforced `FLAG_SECURE` on production release builds to prevent sensitive credentials and terminal scrollbacks from leaking into Android Recents task switcher previews or screen recordings.
- **Encrypted Geolocation Caching:** Wrapped IP geolocation telemetry in an AES-256 encrypted Hive box (`geolocation_cache`) secured with a hardware-backed keystore key.
- **Release-Mode Log Silencing:** Centralized application logging through `AppLogger`, completely suppressing debug, info, warning, and error messages in production release builds to ensure zero credential or telemetry leakage in system logs.

### Stability & Concurrency
- **Chunked Streamed SFTP Downloads (OOM Elimination):** Refactored SFTP file downloads to pipe chunked data directly from the network socket into disk storage via `IOSink`, eliminating contiguous heap memory buffering and resolving Out-Of-Memory (OOM) crashes on large file transfers.
- **Terminal Multi-Byte UTF-8 Boundary Streaming:** Upgraded PTY terminal stream decoding to use stateful `Utf8Decoder(allowMalformed: true)`, preventing terminal crashes and unhandled exceptions when multibyte Unicode characters are split across consecutive TCP packets.
- **Riverpod Provider Optimization:** Decoupled monolithic state models and introduced selective Riverpod `.select()` subscriptions in `ServerMonitorViewModel`, eliminating UI cascade rebuild storms during high-frequency telemetry polling.
- **Connection Mutex & Socket Leak Prevention:** Added connection locks to prevent duplicate connection races during concurrent background polling and interactive terminal launches, alongside explicit cleanup hooks for zombie sockets.

### UI/UX & Operations
- **Remote Server Management Actions:** Added direct server lifecycle management actions to the dashboard and server details screens: Duplicate Server Configuration, Remote Reboot (`sudo reboot || reboot`), and Remote Power Off (`sudo poweroff || poweroff`).
- **Terminal Keyboard Toolbar & Clipboard Paste:** Added sticky modifier keys (Ctrl and Alt) to the terminal screen that translate keystrokes into ASCII control bytes (`0x00..0x1F`) and escape characters (`\x1b`). Added an integrated clipboard paste button to immediately dispatch text to the active PTY shell.
- **Android 11+ Scoped Storage Integration:** Migrated SFTP download destination selection to `FilePicker.getDirectoryPath` for Android 11+ (API 30+) Scoped Storage compliance, paired with asynchronous sharing via `SharePlus`.
- **Server Reordering Fix:** Corrected server management drag-handle index binding in `ManageServersScreen`, restoring reordering functionality and batch selection workflows.
- **Hardware-Accelerated Visualizations:** Enhanced dashboard metrics with custom `CpuLineChart` dynamic scaling and `DiskUsageGauge` radial indicators with danger-threshold color progression.

---

## [1.1.1] - 2026-03-25

### Security & Architecture
- **Data at Rest Encryption:** Migrated local server database to AES-256 encrypted Hive storage. ([#3](https://github.com/yadukrishnan-h/Orbit/issues/3))
- **Dependency Resolution:** Removed the legacy Isar database deadlock and unblocked transitive dependency constraints. ([#4](https://github.com/yadukrishnan-h/Orbit/issues/4))
- **Anti-Tamper Lockout:** Implemented system clock manipulation detection for the Master PIN to prevent time-travel brute-force bypasses.
- **Memory Leak Resolution:** Implemented aggressive garbage collection and `.autoDispose` for background SSH/SFTP sessions.

### Performance
- **Isolate Optimization:** Eliminated Isolate thrashing in the monitoring engine, resulting in massively reduced battery consumption and UI stutter. ([#5](https://github.com/yadukrishnan-h/Orbit/issues/5))

### UI / UX
- **Responsive Dialogs:** Re-engineered the Language Selection dialog for modern edge-to-edge displays.
- **Disk Usage Odometer:** Upgraded the Dashboard Disk metric to a premium radial gauge with dynamic danger-state coloring.
- **Native Legal Viewer:** Embedded Privacy Policy and Terms of Service natively using custom-themed Markdown rendering.
- **SFTP Stability:** Introduced a non-dismissible blocking UI during initial file tree fetches to prevent ghost touches and race conditions.
- **In-App Updates:** Integrated native Google Play Store update checking.

---

## [1.1.0] - 2026-03-12

### Security
- **Encrypted Enclave Migration**: Migrated to AES-256 encrypted storage for SSH keys via OS-level security modules (Keychain/Keystore).
- **Brute-Force Protection**: Implemented persistent 3-phase lockout mechanisms for Master PIN (30s lockout after 5 attempts).
- **Secure Persistence**: Fully transitioned to `flutter_secure_storage` for sensitive credential management.

### Architecture
- **Hive Database Transition**: Completed migration from Isar to Hive (NoSQL) for high-performance metric storage.
- **Off-Main-Thread Concurrency**: Intensive SSH metric parsing moved to background Isolates to prevent UI jank.
- **Robust Error Handling**: Resolved critical async race conditions and "zombie" sessions in the monitoring engine.
- **SSH Stability**: Improved PEM format normalization and ad-hoc command timeout handling.

### Android 15 & System Compatibility
- **Edge-to-Edge Display**: Full support for system-led edge-to-edge rendering and dynamic inset handling.
- **16 KB Page Alignment**: Optimized native binaries for compatibility with next-gen Android hardware.

### UI / UX
- **Terminal Optimization**: Implemented batched output processing for high-frequency terminal updates.
- **Dashboard Reactivity**: Refactored metric cards for optimized rebuilds and real-time responsiveness.
- **Modernized Layout**: Enhanced dark-mode aesthetics with Material 3 refinements.

---
*Built with ❤️ by Yadu Krishnan H*

[1.2.0]: https://github.com/yadukrishnan-h/Orbit/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/yadukrishnan-h/Orbit/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/yadukrishnan-h/Orbit/releases/tag/v1.1.0
