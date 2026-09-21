# Invoxa

> **Simple, Modern Invoicing for Small Businesses and Independent Professionals**

Invoxa is a cross-platform mobile and desktop invoicing application built with **Flutter** and **Firebase**. It provides a clean, distraction-free environment to manage customers, catalog products and services, create professional invoices with automatic total calculations, track client payments, and monitor business growth from a centralized dashboard.

---

## 📚 Project Documentation Hub

The project repository includes comprehensive documentation covering all aspects of development:

| Document                                          | Purpose                                                                                                  |
| ------------------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| [**PRD.md**](docs/PRD.md)                         | Product Requirements Document: Vision, target personas, user flows, and functional requirements.         |
| [**ARCHITECTURE.md**](docs/ARCHITECTURE.md)       | System architecture: Layered pattern, ER diagrams, data flow, auth gates, and Firestore security.        |
| [**ProjectStruture.md**](docs/ProjectStruture.md) | Comprehensive directory & file guide: Detailed explanation of every folder, file, usage, and boundaries. |
| [**DESIGN.md**](docs/DESIGN.md)                   | Design system: Color palettes, typography, spacing tokens, and component guidelines.                     |
| [**RULES.md**](docs/RULES.md)                     | Engineering standards: Golden rules, coding invariants, security restrictions, and Git workflows.        |
| [**TASKS.md**](docs/TASKS.md)                     | Roadmap & status: Phase progress, immediate sprint checklist, and parked issues.                         |

---

## 🚀 Key Features

- **Secure Multi-Tenant Authentication:** Email/password sign-up, login, verification, and password reset backed by Firebase Authentication and Cloud Firestore user profiles (`users/{uid}`).
- **Strict Data Isolation:** Every customer, product, invoice, and payment is strictly scoped to `request.auth.uid`. No cross-user leakage.
- **Client & Customer Management:** Centralized address book of clients with billing details and invoice history.
- **Goods & Services Catalog:** Flexible product and hourly service management with standardized pricing.
- **Smart Invoicing:** Create invoices by selecting customers and line items. Instant calculation of subtotals, taxes, discounts, and totals.
- **Payment Tracking:** Log incoming payments, recalculate balances in real time, and auto-update invoice status (`Draft`, `Pending`, `Partially Paid`, `Paid`, `Overdue`).
- **Executive Dashboard:** At-a-glance KPI metric cards, quick action shortcuts, and recent invoice activity.

---

## 🛠 Tech Stack & Architecture

- **Framework:** [Flutter](https://flutter.dev/) (Null-safe Dart)
- **Backend:** [Firebase](https://firebase.google.com/)
  - Firebase Authentication (User sessions & security tokens)
  - Cloud Firestore (NoSQL tenant-isolated document database)
  - Firebase Storage (Planned for receipts and PDF invoices)
- **State Management:** [Provider](https://pub.dev/packages/provider) (`ChangeNotifier`)
- **Architecture:** Strict Layered Architecture:
  $$\text{Screen (UI)} \longrightarrow \text{Provider (State)} \longrightarrow \text{Service (Backend)} \longrightarrow \text{Cloud Firestore}$$

---

## 💻 Getting Started & Local Setup

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>=3.0.0`)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / Xcode / VS Code with Flutter extension
- Firebase CLI & FlutterFire CLI (configured for Android/iOS/Web)

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/anujgoswami6155/Invoxa.git
   cd Invoxa
   ```

2. **Install Flutter dependencies:**

   ```bash
   flutter pub get
   ```

3. **Verify Static Analysis:**

   ```bash
   flutter analyze
   ```

4. **Run the Application:**
   ```bash
   flutter run
   ```

---

## 🌿 Git Workflow & Collaboration

All development occurs on dedicated feature branches branched from `main`. **Never commit directly to `main`.**

### Development Branches

- `main` — Stable production branch
- `feature/authentication` — Auth flow & user profiles (Completed)
- `feature/dashboard` — Dashboard UI & KPI cards (Current active branch)
- `feature/customers` — Customer management module
- `feature/products` — Product & service catalog module
- `feature/invoices` — Invoicing builder module
- `feature/payments` — Payment tracking module

### Workflow Steps

```bash
# 1. Update main branch
git checkout main
git pull origin main

# 2. Create feature branch
git checkout -b feature/<feature-name>

# 3. Implement & test
flutter analyze

# 4. Commit with Conventional Commits
git commit -m "feat: add dashboard summary cards"

# 5. Push and open a Pull Request
git push -u origin feature/<feature-name>
```

---

## 🔒 Security Principles

1. All Firestore documents must be scoped to the authenticated user's UID (`userId == request.auth.uid`).
2. Global read/write security rules (`allow read, write: if true;`) are strictly forbidden.
3. Private keys, service credentials, and sensitive configurations must never be committed.

---

## 📄 License

This project is proprietary and intended for internal development.
