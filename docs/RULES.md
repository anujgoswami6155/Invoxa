# Invoxa — Engineering Rules & Development Standards

This document establishes the mandatory rules and engineering guidelines for the Invoxa codebase. All contributors must strictly adhere to these standards.

---

## 1. Golden Rule

> **KEEP THE CODE SIMPLE, MODULAR, SECURE, AND UNDERSTANDABLE.**  
> Build one feature at a time. Do not over-engineer. Do not break working authentication. Do not bypass Firebase security. Do not mix UI, state management, and Firebase operations.

---

## 2. Architectural Invariants

### 2.1 Layered Boundary Enforcement
The data flow in Invoxa is strictly unidirectional:
$$\text{Screen (UI)} \longrightarrow \text{Provider (State)} \longrightarrow \text{Service (Backend)} \longrightarrow \text{Firebase}$$

- **NO Direct Firebase Calls in UI:**  
  *Never* call `FirebaseFirestore.instance` or `FirebaseAuth.instance` inside any `Widget`, `State`, or Screen. All cloud interactions must go through an appropriate Service invoked by a Provider.
- **NO Business Logic in UI:**  
  Screens and widgets are strictly for user input, rendering, and listening to providers. Calculations (totals, taxes, validations) belong in Providers or Utility classes.
- **NO UI Logic in Services:**  
  Services must remain pure Dart classes with zero dependency on `BuildContext`, `Widget`, or `ChangeNotifier`.
- **Existing `UserService` Must Be Preserved:**  
  `lib/services/user_service.dart` was created as part of the core authentication pipeline. Do not delete or rename it.

---

## 3. Security Rules

### 3.1 Strict Tenant Isolation
- Every business document (Customer, Product, Invoice, InvoiceItem, Payment) **must** include a `userId` attribute set to `request.auth.uid`.
- Firestore queries must always filter by `where('userId', isEqualTo: currentUserId)`.
- Never trust a client-supplied user identifier for authorization.

### 3.2 Firestore Security Rules
- **NEVER** write or deploy open security rules:
  ```javascript
  // STRICTLY FORBIDDEN:
  allow read, write: if true;
  ```
- Every collection must enforce owner-only read and write privileges using:
  ```javascript
  allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
  ```

### 3.3 Credentials & Secrets
- Never commit Firebase service account private keys, API secrets, or passwords to Git.
- Never commit private `.env` files containing sensitive credentials.
- `lib/firebase_options.dart` is generated configuration — do not modify it manually.

---

## 4. Code Quality & Flutter Best Practices

### 4.1 Static Analysis
- Run `flutter analyze` after every code modification.
- **Zero Analyzer Warnings:** Code must compile cleanly with `No issues found!` before any commit is made.

### 4.2 Null Safety & Immutability
- Fully utilize Dart's sound null safety. Avoid force-unwrapping (`!`) unless guaranteed by a prior null-check.
- Mark constructors as `const` wherever possible to optimize Flutter's widget rebuild cycle.
- Model classes should use immutable fields (`final`) and provide `copyWith()` methods for updates.

### 4.3 Clean Code & Anti-Patterns
- **No Giant Files:** Keep widgets modular. If a widget exceeds 200 lines or is used in multiple places, extract it to `lib/widgets/` or a dedicated sub-widget.
- **No Hardcoded Strings / Magic Numbers:** Use `lib/utils/constants.dart`, `app_enums.dart`, and centralized padding tokens.
- **Centralize Formatting:** Always format currencies, numbers, and dates using `lib/utils/formatters.dart`.
- **Centralize Validation:** Form fields must use validator functions from `lib/utils/validators.dart`.

---

## 5. Git Workflow & Branching Strategy

### 5.1 Branching Model
The repository uses feature-based branches. `main` is protected and represents the stable production state.

**Designated Development Branches:**
- `main` (Production / Stable)
- `feature/authentication` (Merged / Complete)
- `feature/dashboard` (Current Active Branch)
- `feature/customers` (Customer CRUD)
- `feature/products` (Product & Service Catalog)
- `feature/invoices` (Invoice Builder & Management)
- `feature/payments` (Payment Tracking & History)

### 5.2 Development Lifecycle
1. Ensure your local `main` is up to date:
   ```bash
   git checkout main
   git pull origin main
   ```
2. Create your dedicated feature branch:
   ```bash
   git checkout -b feature/<feature-name>
   ```
3. Implement small, logical changes incrementally.
4. Verify with the analyzer:
   ```bash
   flutter analyze
   ```
5. Commit using Conventional Commits.
6. Push and create a Pull Request against `main`.
7. Complete peer review, then **Squash & Merge** into `main`.

### 5.3 Commit Message Standard
Commit messages must follow the **Conventional Commits** specification:
- `feat:` A new user-facing feature (e.g., `feat: add dashboard summary cards`)
- `fix:` A bug fix (e.g., `fix: correct invoice subtotal calculation`)
- `refactor:` Code restructuring without behavioral change (e.g., `refactor: extract stat card to widget`)
- `docs:` Documentation updates (e.g., `docs: update ARCHITECTURE.md`)
- `style:` Formatting, missing semicolons, etc.
- `chore:` Dependency updates, config tweaks

**Forbidden Commit Messages:** `update`, `changes`, `fix`, `test`, `wip`, `final`.

---

## 6. Multi-Developer Collaboration

- **Respect Module Boundaries:** When working on `feature/dashboard`, do not casually modify `AuthProvider`, `AuthService`, or Firestore rules unless strictly required.
- **No Force Pushes to Shared Branches:** Never run `git push --force` on `main`.
- **Communicate Architectural Conflicts:** If a requested feature conflicts with the established architecture, raise the conflict and document the resolution before writing divergent code.
