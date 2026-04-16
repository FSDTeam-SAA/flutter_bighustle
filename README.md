# Bighustle (flutter_bighustle)

![Flutter](https://img.shields.io/badge/Flutter-Cross--Platform-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%5E3.10.1-0175C2?style=flat&logo=dart&logoColor=white)
![GetX](https://img.shields.io/badge/State%20Management-GetX-8A2BE2?style=flat)
![Dio](https://img.shields.io/badge/Networking-Dio-5C2D91?style=flat)
![Version](https://img.shields.io/badge/Version-1.0.0%2B1-success?style=flat)

> A feature-driven Flutter application for driver community engagement, learning resources, licensing workflows, ticket tracking, notifications, and account management.

## Description

**Bighustle** is a Flutter app designed to support drivers through a unified mobile experience that combines community content, educational resources, licensing workflows, ticket management, notifications, and profile controls. The project follows a feature-module architecture, uses **GetX** for dependency injection and state management, and relies on a centralized networking layer built around **Dio**, token handling, and Socket.IO integration for realtime communication.

The codebase is organized for scalability, with clear separation between interface, implementation, controller, model, and presentation layers across each feature domain. Routing is centralized, services are initialized through dedicated dependency injection modules, and repositories use `dartz` `Either` types for explicit error handling.

---

## Table of Contents

- [Overview](#overview)
- [Core Features](#core-features)
- [Modules and Screens](#modules-and-screens)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Configuration](#configuration)
- [Getting Started](#getting-started)
- [Development Notes](#development-notes)
- [Security Notes](#security-notes)

---

## Overview

| Item | Details |
|------|---------|
| **App Name** | Bighustle |
| **Package Name** | `flutter_bighustle` |
| **Platforms** | Android, iOS, Web, Desktop |
| **SDK** | Dart `^3.10.1` |
| **Version** | `1.0.0+1` |
| **Architecture Style** | Feature-module layout |
| **State Management / DI** | GetX |

Bighustle is built to provide a structured, production-oriented driver platform with modular feature boundaries and a maintainable application foundation.

---

## Core Features

### Authentication
- Splash screen boot flow
- Login and signup
- OTP verification
- Forgot password and reset password

### Home Experience
- Bottom navigation-driven main app flow
- Home dashboard
- Community content and teen driver sections
- Teen driver posts and experience sharing
- Learning center and learning video playback

### License Management
- License overview
- License alerts and reminders
- Edit license information workflow
- Add license information within profile flows

### Ticket Management
- Ticket list and ticket details
- Ticket notifications
- Plan pricing details

### Notifications
- In-app notification list
- Feature-level notification handling

### Profile and Settings
- Profile overview
- Personal information and edit flow
- Password change
- Notification settings
- Privacy policy
- Terms and conditions

---

## Modules and Screens

### Auth
- Splash
- Login
- Signup
- OTP Verify
- Forget Password
- Reset Password

### Home
- Bottom Navigation
- Home
- Community
- Teen Drivers
- Teen Driver Posts
- Add Teen Driver Experience
- Learning Center
- Learning Video

### License
- License
- License Alerts
- Edit License Info

### Ticket
- Ticket List
- Ticket Details
- Ticket Notifications
- Plan Pricing Details

### Notifications
- Notification List

### Profile
- Profile
- Personal Info
- Edit Personal Info
- Add License Info
- Change Password
- Notification Settings
- Privacy Policy
- Terms and Conditions

---

## Architecture

### Routing
The app uses a `MaterialApp` with centralized route generation via `onGenerateRoute` and named route definitions managed through `AppRoutes`.

### Module Organization
The project follows a **feature-first layout** under `lib/moduls/`, where each feature can contain:
- interface layer
- implementation layer
- controller layer
- model layer
- presentation/UI layer

This structure improves separation of concerns and makes features easier to scale and maintain.

### Networking
The networking layer is centered around `AppPigeon`, which wraps:
- Dio-based HTTP requests
- authentication interceptors
- refresh token handling
- Socket.IO for realtime updates

### Error Handling
Repositories use a shared `BaseRepository` pattern and `dartz` `Either` values to make success and failure paths explicit.

### Dependency Injection
Dependency injection is configured through GetX using:
- `externalServiceDI()`
- `initServices()`

This setup keeps service registration centralized and makes initialization predictable across environments.

---

## Tech Stack

### Framework and Language
- **Flutter** for cross-platform app development
- **Dart** for application logic

### State Management and Dependency Injection
- `get`

### Networking and Realtime
- `dio`
- `socket_io_client`

### Storage and Security
- `flutter_secure_storage`

### Functional Error Handling
- `dartz`

### Media and Device Access
- `image_picker`
- `video_player`
- `path_provider`

---

## Project Structure

```text
lib/
  main.dart                         # App entry point and routing
  app/                              # App-level controllers and bootstrapping
  core/                             # Constants, DI, API helpers, services
  moduls/                           # Feature modules
    auth/                           # Auth interfaces, impls, controllers, UI
    home/                           # Home, community, teen driver, learning
    license/                        # License flows and alerts
    notification/                   # Notification data and UI
    profile/                        # Profile and settings
    ticket/                         # Ticket list/details and pricing
assets/
  images/                           # Image assets
  videos/                           # Video assets
```

---

## Configuration

Key configuration files and locations:

- **API base URL and socket URL**: `lib/core/constants/api_endpoints.dart`
- **App routes**: `lib/core/constants/app_routes.dart`
- **Dependency injection**:
  - `lib/core/di/external_service_di.dart`
  - `lib/core/di/internal_service_di.dart`
- **Assets configuration**: `pubspec.yaml`

---

## Getting Started

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Run the app

```bash
flutter run
```

### 3. Build for a target platform

Examples:

```bash
flutter build apk
flutter build ios
flutter build web
```

> Make sure Flutter is installed and configured correctly for your target platform before building.

---

## Development Notes

- Keep routes centralized and consistent with `AppRoutes`.
- Prefer feature-based additions under `lib/moduls/` instead of placing new screens in shared folders without ownership.
- Reuse the shared networking and repository layers instead of introducing isolated API clients.
- Keep controllers focused on state and orchestration; push data access into repositories and services.
- Preserve the existing DI bootstrapping flow through `externalServiceDI()` and `initServices()`.

---

## Security Notes

- Do **not** commit API keys, tokens, or production credentials to the repository.
- Use `flutter_secure_storage` for sensitive token handling.
- Prefer environment-specific configuration for secrets and deployment values.
- Review logs and debug output before release to avoid exposing sensitive runtime data.

---

## Summary

Bighustle is a modular Flutter application built for driver-focused workflows and content delivery. It combines community, learning, license management, ticket handling, notifications, and account management in a scalable structure supported by GetX, Dio, and a centralized service architecture.










<!-- # Bighustle (flutter_bighustle)

Bighustle is a Flutter app focused on driver community content, learning resources, licensing workflows, tickets, and account management. The project uses a feature-module layout with GetX for dependency injection, a centralized networking layer, and explicit route definitions for every screen.

## Overview
- App name: Bighustle
- Package name: flutter_bighustle
- Platforms: Android, iOS, Web, Desktop (Flutter)
- SDK: Dart ^3.10.1
- Version: 1.0.0+1

## Core Features
- Authentication flows with splash, login, signup, OTP verification, and password reset
- Home dashboard with community and teen driver content
- Learning center and video playback
- License management, alerts, and editing flows
- Ticket list, ticket details, and ticket notifications
- In-app notifications
- Profile management with personal info, password changes, and settings

## Modules And Screens
- Auth: Splash, Login, Signup, OTP Verify, Forget Password, Reset Password
- Home: Bottom Navigation, Home, Community, Teen Drivers, Teen Driver Posts, Add Teen Driver Experience, Learning Center, Learning Video
- License: License, License Alerts, Edit License Info
- Ticket: Ticket List, Ticket Details, Ticket Notifications, Plan Pricing Details
- Notifications: Notification List
- Profile: Profile, Personal Info, Edit Personal Info, Add License Info, Change Password, Notification Settings, Privacy Policy, Terms and Conditions

## Architecture
- Routing: `MaterialApp` with centralized `onGenerateRoute` and `AppRoutes`
- Modules: Feature-first layout under `lib/moduls/` with interface, implement, controller, model, and presentation layers
- Networking: `AppPigeon` wraps Dio, auth interceptor, refresh token flow, and Socket.IO
- Error handling: `BaseRepository` with `dartz` Either for failures
- Dependency injection: GetX `Get.put` via `externalServiceDI()` and `initServices()`

## Key Packages
- `get` for dependency injection and state
- `dio` for networking
- `socket_io_client` for realtime updates
- `flutter_secure_storage` for secure token storage
- `dartz` for functional error handling
- `image_picker` and `video_player` for media
- `path_provider` for filesystem paths

## Project Structure
```
lib/
  main.dart                         # App entry point and routing
  app/                              # App-level controllers and bootstrapping
  core/                             # Constants, DI, API helpers, services
  moduls/                           # Feature modules
    auth/                           # Auth interfaces, impls, controllers, UI
    home/                           # Home, community, teen driver, learning
    license/                        # License flows and alerts
    notification/                   # Notification data and UI
    profile/                        # Profile and settings
    ticket/                         # Ticket list/details and pricing
assets/
  images/                           # Image assets
  videos/                           # Video assets
```

## Configuration
- API base and socket URLs: `lib/core/constants/api_endpoints.dart`
- App routes: `lib/core/constants/app_routes.dart`
- Dependency injection: `lib/core/di/external_service_di.dart`, `lib/core/di/internal_service_di.dart`
- Assets: `pubspec.yaml`

## Getting Started
1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```
   tes
Keep API keys, tokens, and production credentials out of the repo. Use secure storage and environment-specific configuration for sensitive values. -->
