# Orbit Codebase Analysis & Improvement Plan

This document provides a detailed architectural analysis of the Orbit Flutter application. It outlines existing strengths, identifies areas for improvement, and proposes a plan for refactoring and enhancement.

## 1. Project Overview

Orbit is a Flutter-based mobile application for managing servers via SSH and SFTP. It provides features like a dashboard with real-time server statistics, a file browser, and an SSH terminal. The application is built with a modern Flutter stack, leveraging Riverpod for state management, GoRouter for navigation, and `dartssh2` for the core SSH functionality.

## 2. Architectural Strengths

*   **Modern State Management:** The project correctly uses `flutter_riverpod`, a robust and scalable state management solution. The use of `StreamProvider.family` in `polling_service.dart` is a good example of applying the right provider for the job.
*   **Immutable Models:** The use of `freezed` for data models (`server.dart`, `server_stats.dart`) ensures immutability, which reduces side effects and makes state easier to reason about.
*   **Secure Storage:** `secure_storage_service.dart` correctly utilizes `flutter_secure_storage` with appropriate iOS accessibility options (`KeychainAccessibility.first_unlock`) to protect sensitive credentials.
*   **Testability:** The use of a factory pattern (`SSHClientFactory` in `ssh_service.dart`) is a good practice that facilitates mocking and testing.

## 3. Detailed Analysis and Actionable Recommendations

### 3.1. Bugs & Vulnerabilities

*   **Potential Resource Leak in `PollingService`**:
    *   **File:** `lib/features/dashboard/services/polling_service.dart`
    *   **Issue:** The `streamStats` method creates an SSH client but relies on the stream being cancelled for the `finally` block to execute and close the client. If the consumer of the stream (the UI) disposes without properly closing the stream controller, the `SSHClient` might not be closed, leading to resource leaks on the server and the device.
    *   **Recommendation:** While `autoDispose` helps, ensure all stream subscriptions are properly managed. Consider implementing a more robust lifecycle management for the `SSHClient` within the polling service, perhaps with an explicit `dispose` method that can be called.

*   **"Fire and Forget" Database Call**:
    *   **File:** `lib/features/dashboard/services/polling_service.dart`
    *   **Issue:** The line `_serverService.updateSnapshot(server.id, stats);` is a "fire and forget" call. If `updateSnapshot` fails or is slow, the error is swallowed, and it could potentially cause issues with subsequent polling cycles.
    *   **Recommendation:** Wrap the call in a `try-catch` block to log any potential errors. While you may not want to `await` it and block the polling loop, logging is essential for debugging.

### 3.2. Code Smells & Refactoring Opportunities

*   **Complex Auth Logic in UI Layer**:
    *   **File:** `lib/main.dart`
    *   **Issue:** The `_MyAppState` widget contains complex business logic for determining the authentication state (`_determineAuthState`). This logic, involving multiple `async` calls and `setState`, makes the root widget hard to read and test.
    *   **Recommendation:** Refactor this logic into a dedicated `StateNotifierProvider`. This provider would encapsulate the auth state (`AuthState` enum) and the logic to transition between states. The UI (`MyApp`) would simply listen to this provider and build the appropriate screen, removing all `setState` calls and async logic from the widget itself.

*   **Brittle String-Based Parsing**:
    *   **File:** `lib/core/utils/linux_parser.dart` (and its usage in `polling_service.dart`)
    *   **Issue:** The `polling_service.dart` runs a single long command and parses the string output. The comment `// Bulletproof Parsing (Danger Zone)` in `polling_service.dart` indicates this is a known fragile area. The parser is tightly coupled to the specific output format of Linux commands, which can vary between distributions or even versions of the same tool.
    *   **Recommendation:** Instead of one large command, execute individual, well-defined commands for each piece of data (e.g., `cat /proc/uptime` for uptime, `free -b` for memory). Parse the output of each command separately. For CPU, use a more structured format if available (`/proc/stat` is okay, but requires careful calculation). This makes the parsing logic for each piece of data simpler and more robust. The small overhead of multiple commands is worth the increase in reliability.

*   **Implicit Client Management**:
    *   **File:** `lib/core/services/ssh_service.dart`
    *   **Issue:** The `connect` method's documentation states, `The caller is responsible for closing the client`. This is a common pattern but is prone to developer error, leading to resource leaks.
    *   **Recommendation:** Introduce a wrapper method that handles the client lifecycle for common operations. For example, a method like `executeWithClient(Future<T> Function(SSHClient) block)` could handle the `connect`, `try/catch/finally`, and `close` logic, and the caller would only need to provide the code to be executed with the client.

### 3.3. Enhancement Recommendations

*   **Consolidate Database Strategy**:
    *   **Issue:** The `pubspec.yaml` shows `hive` and `shared_preferences`. While they have different use cases (Hive for structured data, SharedPreferences for simple key-value), this increases complexity.
    *   **Recommendation:** Evaluate if all local storage needs can be met by a single solution. Hive is capable of handling simple key-value storage in addition to more complex objects. Migrating settings from `shared_preferences` to a dedicated "settings" box in Hive would unify the data layer. The `settings_provider.dart` would then use the `HiveService` instead of `SharedPreferences`.

*   **Introduce a Proper Logger**:
    *   **Issue:** The project uses `debugPrint` and `developer.log` inconsistently. There is no centralized logging strategy.
    *   **Recommendation:** Integrate a robust logging package like `logger`. Configure it to have different log levels and outputs for debug and release builds. This will make debugging much easier and provide better insight into the application's behavior in production.

*   **Improve UX for Polling**:
    *   **Issue:** The polling is set to a fixed 3-second interval. This may not be optimal for all network conditions or for battery life.
    *   **Recommendation:**
        1.  **Make the interval configurable:** Allow the user to change the polling frequency in the settings.
        2.  **Implement backoff strategy:** If a poll fails due to a network error, increase the delay before the next attempt.

## 4. Standard Compliance

The project generally follows good Flutter and Dart practices.

*   **Linting:** The project uses `flutter_lints`, which is good. Ensure the linter is run as part of the CI pipeline.
*   **File Structure:** The feature-based file structure (`lib/features/...`) is scalable and easy to navigate.
*   **Riverpod Usage:** The usage of Riverpod is mostly correct, but the recommendation to move auth logic from `main.dart` into a `StateNotifierProvider` would bring it more in line with best practices.

This report should serve as a guide for future development and refactoring efforts. By addressing these points, Orbit can become more robust, maintainable, and performant.
