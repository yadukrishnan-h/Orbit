# Security Policy for Orbit

## Overview
Orbit is built with a strict **private-by-design** and **offline-first** architecture. We take the security of your SSH credentials and biometric data extremely seriously. This policy outlines how we handle security vulnerabilities and our commitment to your privacy.

## Supported Versions
We currently provide security updates for the following versions of Orbit:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0.0 | :x:                |

## Reporting a Vulnerability
**Please do not report security vulnerabilities through public GitHub issues.** If you discover a potential security vulnerability, we ask that you report it to us privately. This allows us to fix the issue before it is exploited.

### How to Report
Please send an email to **[INSERT YOUR EMAIL HERE]** with the following details:
1. **Description:** A brief summary of the vulnerability.
2. **Steps to Reproduce:** A clear list of steps or a Proof of Concept (PoC) script.
3. **Impact:** What could an attacker achieve with this vulnerability?

We will acknowledge your report within **48 hours** and provide a timeline for a fix.

## Our Security Commitments
* **Zero-Knowledge Architecture:** Your SSH keys, passwords, and passphrases are stored strictly in your device's secure hardware (Keystore/Keychain) and are never transmitted to any external server.
* **No Middlemen:** Orbit establishes direct, encrypted peer-to-peer connections between your device and your server.
* **No Tracking:** We do not use third-party analytics or tracking scripts that could leak metadata about your infrastructure.
* **Open Source Transparency:** Our code is open for public audit to ensure our security claims are verifiable by the community.

## Security Audits
We welcome independent security researchers to audit our codebase. If you are interested in performing a formal audit, please contact us via the email provided above.
