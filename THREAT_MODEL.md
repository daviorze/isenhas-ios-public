# Threat Model

This document describes the threat assumptions and security goals of the iSenhas iOS client.

---

## Security Goals

The primary goals of iSenhas are:

* Protect user secrets at rest
* Prevent unauthorized vault access
* Minimize sensitive data exposure
* Protect encryption keys
* Reduce impact of device compromise
* Maintain privacy even against service operators

---

## Protected Assets

* User passwords and credentials
* Encryption keys
* Vault metadata
* Authentication tokens
* Locally cached sensitive data

---

## Attacker Model

The attacker may:

* Obtain physical access to the device
* Extract application storage files
* Attempt offline vault decryption
* Intercept network traffic
* Reverse engineer the application binary
* Analyze application behavior

The attacker is assumed **not** to control:

* Apple Secure Enclave hardware
* Verified biometric authentication
* Trusted OS cryptographic primitives

---

## Defense-in-Depth Strategy

iSenhas uses multiple independent security layers:

* Strong key derivation
* Client-side encryption
* Secure Keychain storage
* Biometric protection
* Session expiration

Security does not depend on any single mechanism.

---

## Out-of-Scope Threats

The following scenarios are considered outside the protection guarantees:

* Fully compromised operating system
* Active malware with privileged device access
* User voluntarily disclosing credentials
* Screen recording or shoulder surfing attacks
* Compromised Apple platform security

---

## Privacy Assumptions

iSenhas is designed so that:

* Servers cannot read user secrets in Zero-Knowledge mode
* Sensitive data remains encrypted during storage and transmission
* User control over encryption keys is prioritized

---

## Continuous Improvement

The threat model evolves as new attack techniques emerge.

Security assumptions may change as the platform and threat landscape evolve.

---

iSenhas — Security Through Transparency
