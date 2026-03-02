# iSenhas for iOS (Public Client)

iSenhas is a privacy-focused password manager designed with security, transparency, and user control as core principles.

This repository contains the **public client implementation** of the iSenhas iOS application.

---

## 🔐 Security

Security and transparency are fundamental principles of iSenhas.

This repository provides public access to the client-side application code, enabling independent security review and community auditing of how user data is protected on-device.

### Security Documentation

* 📄 [Security Policy](SECURITY.md)
* 🛡️ [Threat Model](THREAT_MODEL.md)

### Security Features

* Client-side encryption
* AES-256 vault encryption
* Secure key derivation
* Apple Keychain integration
* Secure Enclave usage when available
* Biometric authentication support
* Defense-in-depth architecture

We welcome responsible security research and community feedback.

---

## 📱 Repository Scope

This public repository exists to provide **transparency and auditability** of the iSenhas iOS client.

This repository is not intended to build a runnable application.
It exists solely to document and expose the security architecture and cryptographic design of the iSenhas iOS client for independent review.

Included in this repository:

* iOS application source code
* Local vault management
* Client-side cryptographic workflow
* Device security integrations
* Security architecture documentation

Not included:

* Backend infrastructure
* Production APIs
* Synchronization services
* Authentication servers
* Anti-abuse and fraud prevention systems
* Internal operational tooling
* UI/UX

Some components of iSenhas are intentionally maintained in private repositories for operational security.

---

## 🧠 Security Model

iSenhas supports different operational modes depending on user preference.

### Extreme Privacy Mode (Recommended)

* Zero-Knowledge encryption
* Encryption occurs locally on the device
* Master password and Recovery Key never leaves the device
* Servers store only encrypted data
* Server operators cannot access user secrets

### Cloud Convenience Mode

* Enables additional usability and recovery features
* May involve limited server-side processing depending on configuration
* Designed for users prioritizing convenience and account recovery options

Users can choose the model that best fits their security expectations.

---

## 🔍 Transparency Commitment

The purpose of this repository is to allow:

* Independent security review
* Community auditing
* Architectural transparency
* Verification of privacy guarantees

Security should be verifiable, not based on hidden implementation details.

---

## ⚠️ Important Notice

This repository represents the **public client components** of iSenhas.

The official iSenhas service includes additional proprietary systems and infrastructure not included here.

---

## 🛡️ Responsible Disclosure

If you discover a security vulnerability, please report it responsibly:

**[davi@isenhas.com.br](mailto:davi@isenhas.com.br)**

Please avoid public disclosure before coordinated remediation.

---

## 📄 License

This project is distributed under the **iSenhas Source Available License (ISAL)**.

The source code is provided for transparency, research, and security auditing purposes.

Commercial use, redistribution, or creation of competing products is not permitted.

See the LICENSE file for details.

---

## 🤝 Contributing

Security feedback, discussions, and improvement suggestions are welcome.

If reporting a vulnerability, please use responsible disclosure instead of opening a public issue.

---

## 🚀 Project Goals

* Privacy by default
* User data ownership
* Transparent security architecture
* Strong local encryption
* Trust through verifiable security

---

**iSenhas — Security without compromise.**
