# Invoxa — Project Structure & File Guide

This document explains the complete directory and file layout of the Invoxa application. It details the purpose of each directory and file, why it exists, what responsibilities it handles, and how developers should interact with it.

---

## 1. Directory Tree Overview

```text
Invoxa/
│
├── lib/
│   ├── main.dart                          # Application entry point & provider tree
│   ├── firebase_options.dart              # Generated Firebase configuration
│   │
│   ├── models/                            # Domain data models & serializations
│   │   ├── user_model.dart                # User profile model
│   │   ├── customer_model.dart            # Customer / client entity model
│   │   ├── product_model.dart             # Product / service catalog model
│   │   ├── invoice_model.dart             # Main invoice entity model
│   │   ├── invoice_item_model.dart        # Line item model within an invoice
│   │   └── payment_model.dart             # Payment transaction entity model
│   │
│   ├── screens/                           # Visual screens organized by domain
│   │   ├── auth/                          # Authentication & onboarding screens
│   │   │   ├── auth_gate.dart             # Root routing decision screen
│   │   │   ├── login_screen.dart          # User login screen
│   │   │   ├── register_screen.dart       # Account registration screen
│   │   │   ├── verify_email_screen.dart   # Email verification waiting screen
│   │   │   └── forgot_password_screen.dart# Password reset request screen
│   │   │
│   │   ├── dashboard/                     # Central dashboard screen
│   │   │   └── dashboard_screen.dart      # Business overview & KPI screen
│   │   │
│   │   ├── customers/                     # Customer management screens
│   │   │   ├── customers_screen.dart      # Customer list view
│   │   │   ├── add_customer_screen.dart   # Customer creation & edit form
│   │   │   └── customer_details_screen.dart # Customer overview, history & dues
│   │   │
│   │   ├── products/                      # Product & service catalog screens
│   │   │   ├── products_screen.dart       # Products / services list
│   │   │   └── add_product_screen.dart    # Product creation & edit form
│   │   │
│   │   ├── invoices/                      # Invoicing workflow screens
│   │   │   ├── invoices_screen.dart       # Invoice list with status filters
│   │   │   ├── create_invoice_screen.dart # Multi-step invoice builder
│   │   │   ├── invoice_details_screen.dart# Itemized invoice & payment history
│   │   │   └── record_payment_screen.dart # Payment entry dialog / screen
│   │   │
│   │   └── profile/                       # User settings & profile
│   │       └── profile_screen.dart        # Business profile & account settings
│   │
│   ├── providers/                         # State management (ChangeNotifier)
│   │   ├── auth_provider.dart             # Auth state, session & verification
│   │   ├── customer_provider.dart         # Customer list, CRUD state & loaders
│   │   ├── product_provider.dart          # Product catalog state & loaders
│   │   ├── invoice_provider.dart          # Invoice state, calculations & filters
│   │   └── payment_provider.dart          # Payment state & invoice balance updates
│   │
│   ├── services/                          # External & Firebase service wrappers
│   │   ├── auth_service.dart              # FirebaseAuth wrapper
│   │   ├── user_service.dart              # Firestore user profile service
│   │   ├── customer_service.dart          # Firestore customer CRUD operations
│   │   ├── product_service.dart           # Firestore product CRUD operations
│   │   ├── invoice_service.dart           # Firestore invoice CRUD operations
│   │   ├── payment_service.dart           # Firestore payment CRUD operations
│   │   └── storage_service.dart           # Firebase Storage (receipts, logos, PDFs)
│   │
│   ├── navigation/                        # Central routing & navigation
│   │   └── app_router.dart                # Named routes and transition handlers
│   │
│   ├── utils/                             # Shared utilities and helpers
│   │   ├── constants.dart                 # App-wide string keys, URLs & dimensions
│   │   ├── validators.dart                # Form validators (email, phone, currency)
│   │   ├── formatters.dart                # Date, currency, and number formatters
│   │   └── app_enums.dart                 # InvoiceStatus, PaymentMethod, etc.
│   │
│   ├── widgets/                           # Shared, reusable UI widgets
│   │   ├── custom_button.dart             # Standardized primary/secondary button
│   │   ├── custom_text_field.dart         # Styled input field with validation
│   │   ├── invoice_card.dart              # Summary card for invoice lists
│   │   ├── customer_card.dart             # Card for customer list entries
│   │   └── dashboard_stat_card.dart       # Metric/KPI card for dashboard
│   │
│   └── theme/                             # Centralized styling & theming
│       └── app_theme.dart                 # Color scheme, typography, card themes
│
├── assets/                                # Static assets
│   ├── images/                            # Logos, illustrations, placeholder art
│   └── icons/                             # Custom SVG or PNG icons
│
├── test/                                  # Unit, widget, and integration tests
├── pubspec.yaml                           # Project dependencies and asset definitions
├── analysis_options.yaml                  # Linter rules and static analysis settings
└── README.md                              # Project overview and getting started guide
```

---

## 2. Directory & File Details

### 2.1 Root & Configuration Files

#### `lib/main.dart`
- **Why it exists:** The mandatory entry point of every Flutter application.
- **Usage:** Initializes Flutter bindings, connects to Firebase using `Firebase.initializeApp()`, registers top-level `MultiProvider` dependencies, and loads the root `MaterialApp` pointing to `AuthGate`.
- **Rules:** Keep it clean. Do not put application screens or inline business logic here.

#### `lib/firebase_options.dart`
- **Why it exists:** Automatically generated by FlutterFire CLI containing platform-specific Firebase API keys and project identifiers (`com.invoxa.invoxa`).
- **Usage:** Passed into `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
- **Rules:** **DO NOT manually edit or rewrite this file.** It is managed configuration.

#### `analysis_options.yaml`
- **Why it exists:** Defines Dart analyzer and linter rules.
- **Usage:** Enforces strict typing, const constructor usage, formatting consistency, and prevents code smells before commit.

#### `pubspec.yaml`
- **Why it exists:** Package manifest detailing dependencies (`firebase_core`, `firebase_auth`, `cloud_firestore`, `provider`, `intl`, etc.) and bundled asset paths.

---

### 2.2 Models (`lib/models/`)
Models define the shape and behavior of core domain entities. They ensure type safety and eliminate raw `Map<String, dynamic>` manipulations across the UI.

- **`user_model.dart`**: Represents the authenticated business user (`uid`, `name`, `email`, `createdAt`). Serializes to and from `users/{uid}`.
- **`customer_model.dart`**: Stores client info (`id`, `userId`, `name`, `email`, `phone`, `address`, `createdAt`). Ensures every client is scoped to the user.
- **`product_model.dart`**: Defines inventory or billable services (`id`, `userId`, `name`, `description`, `unitPrice`, `unitType`).
- **`invoice_model.dart`**: The core billing record (`id`, `userId`, `customerId`, `invoiceNumber`, `issueDate`, `dueDate`, `subtotal`, `taxAmount`, `discountAmount`, `totalAmount`, `paidAmount`, `status`).
- **`invoice_item_model.dart`**: Represents an individual line item inside an invoice (`id`, `productId`, `productName`, `quantity`, `unitPrice`, `totalPrice`).
- **`payment_model.dart`**: Captures a payment transaction against an invoice (`id`, `invoiceId`, `userId`, `amount`, `paymentMethod`, `referenceNumber`, `paymentDate`).

---

### 2.3 Screens (`lib/screens/`)
Screens represent full viewport pages that users navigate between.

#### `lib/screens/auth/`
- **`auth_gate.dart`**: The smart routing switch. If unauthenticated -> `LoginScreen`. If authenticated but unverified -> `VerifyEmailScreen`. If verified -> `DashboardScreen`.
- **`login_screen.dart`**: Form for email & password authentication.
- **`register_screen.dart`**: Account creation form capturing name, email, and password.
- **`verify_email_screen.dart`**: Notice screen instructing the user to confirm their email, with resend and refresh triggers.
- **`forgot_password_screen.dart`**: Form to request a password recovery email.

#### `lib/screens/dashboard/`
- **`dashboard_screen.dart`**: The main post-login landing screen. Displays business metrics (Customers, Products, Invoices, Revenue), quick action triggers, and recent invoices.

#### `lib/screens/customers/`
- **`customers_screen.dart`**: List of all customers with search and filter capabilities.
- **`add_customer_screen.dart`**: Form to create or update customer details.
- **`customer_details_screen.dart`**: Deep dive into customer profile, outstanding dues, and invoice history.

#### `lib/screens/products/`
- **`products_screen.dart`**: Catalog view of all billable goods and services.
- **`add_product_screen.dart`**: Form to define new products, pricing, and service units.

#### `lib/screens/invoices/`
- **`invoices_screen.dart`**: List of invoices with status tabs (`All`, `Pending`, `Paid`, `Overdue`).
- **`create_invoice_screen.dart`**: Interactive builder where users choose a customer, add items, set quantities, and review calculated totals.
- **`invoice_details_screen.dart`**: Itemized invoice view with options to print/share and record payments.
- **`record_payment_screen.dart`**: Form to record incoming payments against an invoice.

#### `lib/screens/profile/`
- **`profile_screen.dart`**: Settings screen for business name, currency preferences, and logout trigger.

---

### 2.4 Providers (`lib/providers/`)
Providers manage in-memory state, loading spinners, errors, and business calculations using `ChangeNotifier`.

- **`auth_provider.dart`**: Central coordinator for auth state, current `UserModel`, loading flags, and error messages.
- **`customer_provider.dart`**: Fetches, caches, adds, and updates customers.
- **`product_provider.dart`**: Manages product list state and item lookups.
- **`invoice_provider.dart`**: Handles invoice creation logic, line item calculations, subtotal/tax computing, and invoice filtering.
- **`payment_provider.dart`**: Dispatches payment creation and coordinates updating invoice payment status.

---

### 2.5 Services (`lib/services/`)
Services contain pure backend communication logic. They interface directly with Firebase SDKs and contain zero UI code.

- **`auth_service.dart`**: Directly invokes `FirebaseAuth` methods (signIn, createUser, signOut, sendEmailVerification, sendPasswordResetEmail).
- **`user_service.dart`**: Interacts with the Firestore `/users/{uid}` collection. *(Existing file — do not remove).*
- **`customer_service.dart`**: Executes Firestore queries and writes for `/customers`.
- **`product_service.dart`**: Executes Firestore queries and writes for `/products`.
- **`invoice_service.dart`**: Executes Firestore queries and transactions for `/invoices`.
- **`payment_service.dart`**: Executes Firestore operations for `/payments`.
- **`storage_service.dart`**: Interacts with Firebase Storage for company logos or PDF receipts.

---

### 2.6 Navigation (`lib/navigation/`)
- **`app_router.dart`**: Central registry for route names (`/login`, `/dashboard`, `/create-invoice`, etc.) and `MaterialPageRoute` generation. Keeps navigation decoupled from screen implementations.

---

### 2.7 Utilities (`lib/utils/`)
- **`constants.dart`**: Application constants, padding values, assets paths, and collection name strings.
- **`validators.dart`**: Pure static functions validating emails, password strength, empty fields, and numeric inputs.
- **`formatters.dart`**: Centralized currency formatting (`₹`, `$`, etc.), date formatting (`dd MMM yyyy`), and invoice number zero-padding.
- **`app_enums.dart`**: Domain enums like `InvoiceStatus` (`draft`, `pending`, `partiallyPaid`, `paid`, `overdue`, `cancelled`) and `PaymentMethod` (`cash`, `bankTransfer`, `card`, `upi`, `other`).

---

### 2.8 Widgets (`lib/widgets/`)
Reusable UI components to prevent code duplication across screens.

- **`custom_button.dart`**: Consistent primary and secondary buttons with built-in loading spinners.
- **`custom_text_field.dart`**: Text form field with uniform borders, labels, prefix icons, and error handling.
- **`invoice_card.dart`**: Standardized card used across invoice lists and dashboard recent invoices.
- **`customer_card.dart`**: Standardized card for client lists.
- **`dashboard_stat_card.dart`**: Clean, elevated card displaying a KPI metric, label, and icon.

---

### 2.9 Theme (`lib/theme/`)
- **`app_theme.dart`**: Houses `ThemeData` configurations (light and dark mode), defining the color scheme, card elevation, font family, button shapes, and input decorations.
