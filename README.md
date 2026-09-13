# Connectify

A modern, full-featured cross-platform Flutter application that seamlessly connects users with local service providers. Browse, search, book, and manage services such as home cleaning, maintenance, repairs, and more — all from an intuitive, responsive interface.

---

## ✨ Features

- **Onboarding & Splash** — Smooth splash screen, animated transitions, and guided walkthrough for new users.
- **Authentication & Security** — Email/password sign-up and login, along with Google Sign-In support powered by Firebase Auth.
- **Service Discovery & Search** — Categorized service listings, sub-service exploration, live search, and detailed service descriptions.
- **Booking & Scheduling** — Select sub-services, specify booking date & time, track service requests, and review status updates.
- **Provider Dashboard & Management** — Dedicated provider tools to manage incoming requests, accept/reject jobs, update completion status, and view customer reviews.
- **Ratings & Reviews** — Share feedback and rating experiences after service completion.
- **Bookmarks & Favorites** — Save preferred providers and quickly access frequent services.
- **User Profile Management** — Cloudinary-powered profile photo uploads and personal profile management synced with Cloud Firestore.
- **Theme Modes (Light / Dark / System)** — Comprehensive theme support with light, dark, and system-adaptive modes, dynamic color schemes, design tokens, and persistent preferences.
- **AI-Powered Chatbot** — Integrated virtual assistant powered by Google Generative AI (Gemini).
- **Push Notifications** — Real-time notifications powered by Firebase Cloud Messaging (FCM).
- **In-App Email Support** — Built-in support page for direct inquiry submission and customer help.
- **Payment Methods** — Support for Credit Card, PayPal, Google Pay, Apple Pay, and Bank Transfer selections.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | [Flutter](https://flutter.dev/) (Dart) |
| **Authentication** | Firebase Authentication & Google Sign-In |
| **Database** | Cloud Firestore |
| **Storage** | Cloudinary |
| **Push Notifications** | Firebase Cloud Messaging (FCM) |
| **AI Integration** | Google Generative AI (Gemini API) |
| **State & Preferences**| SharedPreferences |
| **Email Delivery** | Mailer (SMTP) |
| **Animations & UI** | animate_do & Custom Design Tokens |

---

## 📋 Prerequisites

- Flutter SDK `>=3.5.3`
- Dart SDK `>=3.5.3 <4.0.0`
- A Firebase project with Authentication, Firestore, and Cloud Messaging enabled
- A [Cloudinary](https://cloudinary.com/) account for image uploads
- A Google Gemini API key
- A `.env` file located at the project root containing your API keys and configuration

---

## 🚀 Getting Started

### 1. Clone the repository
```bash
git clone https://github.com/SamiAbuTouq/Connectify.git
cd Connectify
```

### 2. Configure Environment Variables
Create a `.env` file in the root directory and add the necessary environment variables:
```env
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_UPLOAD_PRESET=your_upload_preset
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
GEMINI_API_KEY=your_gemini_api_key
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run the Application
```bash
flutter run
```

### 5. Running Tests
```bash
flutter test
```

---

## 📁 Project Structure

```
lib/
├── main.dart                     # App entry point, Firebase initialization & theme provider
├── routes.dart                   # Named route definitions and navigation arguments
├── theme.dart                    # Light & Dark theme definitions, palettes, and styles
├── design_tokens.dart            # Design system tokens (colors, typography, spacing, elevations)
├── firebase_options.dart         # Firebase CLI configuration
├── module/
│   └── shared_data.dart          # Shared global states, categories, and constants
├── services/
│   ├── auth_service.dart         # Firebase Authentication & Google Sign-In methods
│   ├── db_service.dart           # Firestore database CRUD operations
│   ├── firestore_paths.dart      # Centralized Firestore collection and document paths
│   ├── cloudinary_service.dart   # Image upload and media asset handling via Cloudinary
│   ├── notification_service.dart # Firebase Cloud Messaging (FCM) setup & handlers
│   ├── send_email_service.dart   # SMTP-based email sending service
│   └── theme_service.dart        # Theme mode management & local persistence
├── utils/
│   └── responsive_utils.dart     # Responsive layout, breakpoints, and UI scaling helpers
├── onboarding/
│   ├── splash.dart               # Animated splash screen
│   ├── onboarding_screens.dart   # Walkthrough onboarding pages
│   ├── onboarding_page.dart      # Onboarding wrapper controller
│   └── transitions.dart          # Custom page transition route animations
├── homepage/
│   ├── models/                   # Core data models
│   │   ├── provider_profile.dart # Provider details, bio, and service offerings
│   │   ├── review.dart           # User reviews and ratings
│   │   ├── service.dart          # Service category and sub-service definitions
│   │   ├── service_request.dart  # Booking requests, scheduling, and statuses
│   │   └── user_profile.dart     # Customer profile model
│   ├── pages/                    # Main screens
│   │   ├── home_page.dart        # Main dashboard with bottom navigation
│   │   ├── profile_page.dart     # User profile view and edit screen
│   │   ├── provider_dashboard_page.dart # Provider request management & statistics
│   │   ├── select_provider_page.dart    # Provider selection & booking flow
│   │   ├── chatbot.dart          # AI assistant conversational interface
│   │   ├── help_support_page.dart# Help center, FAQs, and contact links
│   │   └── send_email_page.dart  # In-app customer support email composer
│   └── widgets/                  # Reusable dashboard widgets
│       ├── all_providers_tab.dart# Providers catalog tab with filters
│       ├── bookings_list.dart    # Active and past bookings list
│       ├── bookmarks_tab.dart    # Saved and favorite providers
│       ├── service_card.dart     # Service item card component
│       ├── favorite_button.dart  # Bookmark / favorite toggle button
│       ├── profile_section.dart  # User info header component
│       └── dialogs.dart          # Confirmation and action dialogs
├── views/
│   ├── login.dart                # User sign-in screen
│   ├── signup.dart               # New account registration screen
│   ├── experience.dart           # Experience rating screen
│   ├── upload_img.dart           # Profile photo upload screen
│   ├── select_service_page.dart  # Service category selection screen
│   ├── im_looking_for_screen.dart# Service search and discovery screen
│   └── select_service_1/         # Specialized sub-service selection screens
│       ├── cleaning.dart
│       ├── select_service_1_1.dart
│       ├── select_service_1_2.dart
│       ├── select_service_1_3.dart
│       ├── select_service_1_4.dart
│       ├── select_service_1_5.dart
│       └── select_service_1_6.dart
└── widgets/                      # Shared UI components
    ├── app_drawer.dart           # Main navigation drawer with theme toggle & user info
    ├── button.dart               # Primary and secondary styled buttons
    ├── circular_progress_indicator.dart # Custom loader indicators
    ├── logo.dart                 # App brand logo widget
    ├── select_container_widget.dart     # Selectable container cards
    ├── theme_mode_selector.dart  # Light/Dark/System theme switcher modal & tile
    └── user_image_picker.dart    # Avatar image picker with camera/gallery support
```

---

## 📸 Screenshots

<p align="center">
  <img src="Screenshots/1.png" width="30%" alt="Screenshot 1">
  <img src="Screenshots/2.png" width="30%" alt="Screenshot 2">
  <img src="Screenshots/3.png" width="30%" alt="Screenshot 3">
</p>

<p align="center">
  <img src="Screenshots/4.png" width="30%" alt="Screenshot 4">
  <img src="Screenshots/5.png" width="30%" alt="Screenshot 5">
  <img src="Screenshots/6.png" width="30%" alt="Screenshot 6">
</p>

<p align="center">
  <img src="Screenshots/7.png" width="30%" alt="Screenshot 7">
  <img src="Screenshots/8.png" width="30%" alt="Screenshot 8">
  <img src="Screenshots/9.png" width="30%" alt="Screenshot 9">
</p>

<p align="center">
  <img src="Screenshots/10.png" width="30%" alt="Screenshot 10">
  <img src="Screenshots/11.png" width="30%" alt="Screenshot 11">
  <img src="Screenshots/12.png" width="30%" alt="Screenshot 12">
</p>

<p align="center">
  <img src="Screenshots/13.png" width="30%" alt="Screenshot 13">
  <img src="Screenshots/14.png" width="30%" alt="Screenshot 14">
  <img src="Screenshots/15.png" width="30%" alt="Screenshot 15">
</p>

<p align="center">
  <img src="Screenshots/16.png" width="30%" alt="Screenshot 16">
  <img src="Screenshots/17.png" width="30%" alt="Screenshot 17">
  <img src="Screenshots/18.png" width="30%" alt="Screenshot 18">
</p>

<p align="center">
  <img src="Screenshots/19.png" width="30%" alt="Screenshot 19">
  <img src="Screenshots/20.png" width="30%" alt="Screenshot 20">
  <img src="Screenshots/21.png" width="30%" alt="Screenshot 21">
</p>

<p align="center">
  <img src="Screenshots/22.png" width="30%" alt="Screenshot 22">
</p>
