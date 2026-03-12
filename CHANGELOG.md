# Changelog

All notable changes to the Orbit project will be documented in this file.

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
