<div align="center">

# 🛰️ Orbit

### Your servers, always in sight. A sleek SSH & SFTP manager for your pocket.

[![GitHub Stars](https://img.shields.io/github/stars/yadukrishnan-h/orbit?style=flat-square&logo=github)](https://github.com/yadukrishnan-h/orbit/stargazers)
[![GitHub Forks](https://img.shields.io/github/forks/yadukrishnan-h/orbit?style=flat-square&logo=github)](https://github.com/yadukrishnan-h/orbit/network/members)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

</div>

---

## 📖 About the Project

**Orbit** is a mobile-first SSH and SFTP server management application built with Flutter. It gives developers, sysadmins, and hobbyists a fast, beautiful, and fully-featured way to monitor and manage their Linux servers directly from their phone — no laptop required.

At its core, Orbit establishes persistent SSH connections to your servers and continuously polls key metrics — CPU load, RAM usage, disk utilization, latency, uptime, OS distribution, and kernel version — displaying them in real-time charts and dashboards. The native SFTP subsystem lets you browse, upload, download, rename, and delete remote files with a polished file-manager UI that supports both list and grid views, multi-file selection, breadcrumb navigation, and disk usage indicators.

Orbit is designed with a clean, dark-first aesthetic and a layered feature-per-screen architecture. Each server you add gets its own persistent background monitoring session; the home screen gives you an at-a-glance fleet overview so you always know the health of every machine before you even open a dashboard.

<p align="center">
  <img src="assets/screenshots/Dashboard.png" alt="Orbit Dashboard" width="32%" />
  <img src="assets/screenshots/server-statistics.png" alt="Orbit Server Statistics" width="32%" />
  <img src="assets/screenshots/terminal-screenshots.jpg" alt="Orbit Terminal" width="32%" />
</p>
---

## ✨ Features

- **Fleet Overview**: Monitor all your connected servers from a single, easy-to-read dashboard.
- **Real-Time Monitoring**: Live charts tracking CPU, RAM, Disk, and Network latency using high-performance Hive (NoSQL) storage.
- **Advanced SFTP Client**: Fully-featured file manager. Browse, upload, download, rename, and delete files remotely.
- **Full SSH Terminal & Command Execution**: Run terminal commands directly from your device with batched output processing.
- **Background Active Monitoring**: Connections stay persistent with off-main-thread metric parsing (Isolates).
- **Secure by Design**: All sensitive data is stored in the OS-level encrypted enclave (`flutter_secure_storage`).
- **Advanced Authentication**: Persistent 3-phase Master PIN lockout with brute-force protection.
- **Android 15 Ready**: Full support for Edge-to-Edge displays and 16 KB memory page alignment for next-gen hardware.
- **Dark-First Modern UI**: Designed for clarity, aesthetics, and smooth user experience.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.x or later)
- Android Studio / Xcode for deploying to emulators or physical devices.

### Installation

📥 **Direct Download:** You can download the latest production APK directly from the [Releases](https://github.com/yadukrishnan-h/orbit/releases) section of this repository.

1. **Clone the repository**

   ```bash
   git clone https://github.com/yadukrishnan-h/orbit.git
   cd orbit
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

---

## 🛠️ Architecture & Tech Stack

- **Framework**: [Flutter](https://flutter.dev/)
- **State Management**: [Riverpod](https://riverpod.dev/) for reactive, thread-safe application state.
- **Database**: [Hive](https://pub.dev/packages/hive) for high-performance, encrypted NoSQL storage.
- **Security**: [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage) for OS-level keychain/keystore encryption (AES-256).
- **SSH/SFTP**: [dartssh2](https://pub.dev/packages/dartssh2) for robust, high-performance remote terminal and file management.
- **Concurrency**: Background [Isolates](https://api.flutter.dev/flutter/dart-isolate/Isolate-class.html) for non-blocking metric parsing and monitoring.

---

## 🤝 Contributing

While the source code is public for transparency and educational purposes, **we are not accepting public Pull Requests (PRs) at this time.**

Bug reports, feature requests, and improvement suggestions are highly encouraged! Please open an issue via the Issues tab.

See the [Contributing Guidelines](CONTRIBUTING.md) for more details.

---

## 📜 License

This project is released under a "Source-Available" license, which is STRICTLY PROHIBITED for unauthorized distribution, commercial use, or publishing to app stores.

See the [LICENSE](LICENSE) file for the full terms and conditions.

---

<p align="center">
  Built with ❤️ by <a href="https://github.com/yadukrishnan-h">yadukrishnan-h</a>
</p>
