# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | ✅ Yes             |
| < 0.1.0 | ❌ No              |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security issue in `softlink_flutter`, please report it responsibly.

### How to Report

**Do NOT open a public GitHub issue for security vulnerabilities.**

Instead, please report security vulnerabilities by emailing:

📧 **security@supersoft.com.pk**

Include the following in your report:

- A description of the vulnerability
- Steps to reproduce the issue
- The potential impact of the vulnerability
- Any suggested fixes (optional)

### What to Expect

- **Acknowledgement**: We will acknowledge receipt of your report within **48 hours**
- **Assessment**: We will assess the vulnerability and its impact within **7 days**
- **Fix**: We will work on a fix and release a patched version as soon as possible
- **Credit**: We will credit you in the release notes (unless you prefer to remain anonymous)

### Scope

The following are in scope for security reports:

- Vulnerabilities in the `softlink_flutter` SDK code
- Issues with device identifier handling or storage
- Data leakage via the SDK
- Authentication/authorization bypass related to API key handling

### Out of Scope

- Vulnerabilities in third-party dependencies (report to those projects directly)
- Issues requiring physical access to the device
- Social engineering attacks

## Security Best Practices

When using `softlink_flutter`:

1. **Keep your API key private** — Never expose your SoftLink API key in public repositories
2. **Use HTTPS** — Always use `https://` for your `baseUrl`
3. **Keep the SDK updated** — Always use the latest version for security patches
4. **Validate deep link data** — Always validate `screen` and `params` values before navigation

## Disclosure Policy

We follow **Coordinated Vulnerability Disclosure**. We ask that you:

1. Give us reasonable time to fix the issue before public disclosure
2. Avoid accessing or modifying user data beyond what is necessary to demonstrate the vulnerability
3. Act in good faith and avoid causing harm

Thank you for helping keep `softlink_flutter` and its users safe! 🙏