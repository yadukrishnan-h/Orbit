# Changelog

All notable changes to the Orbit project will be documented in this file.

## [1.1.1] - 2026-03-24

### Security & Architecture
- **Data at Rest Encryption:** Migrated local server database to AES-256 encrypted Hive storage.
- **Anti-Tamper Lockout:** Implemented system clock manipulation detection for the Master PIN to prevent time-travel brute-force bypasses.
- **Memory Leak Resolution:** Implemented aggressive garbage collection and `.autoDispose` for background SSH/SFTP sessions.
- **Isolate Optimization:** Eliminated Isolate thrashing in the monitoring engine, resulting in massively reduced battery consumption and UI stutter.

### UI / UX
- **Responsive Dialogs:** Re-engineered the Language Selection dialog for modern edge-to-edge displays.
- **Disk Usage Odometer:** Upgraded the Dashboard Disk metric to a premium radial gauge with dynamic danger-state coloring.
- **Native Legal Viewer:** Embedded Privacy Policy and Terms of Service natively using custom-themed Markdown rendering.
- **SFTP Stability:** Introduced a non-dismissible blocking UI during initial file tree fetches to prevent ghost touches and race conditions.
- **In-App Updates:** Integrated native Google Play Store update checking.

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

### Android 15
- **Edge-to-Edge Display**: Full support for system-led edge-to-edge rendering and dynamic inset handling.
- **16 KB Page Alignment**: Optimized native binaries for compatibility with next-gen Android hardware.

### UI / UX
- **Terminal Optimization**: Implemented batched output processing for high-frequency terminal updates.
- **Dashboard Reactivity**: Refactored metric cards for optimized rebuilds and real-time responsiveness.
- **Modernized Layout**: Enhanced dark-mode aesthetics with Material 3 refinements.

---
*Built with ❤️ by Yadu Krishnan H*
