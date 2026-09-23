# Salesman Tracking App

A Flutter-based salesman tracking application designed to help administrators manage salesmen, monitor field activities, and track trips and visits in real time.

The application uses Flutter with BLoC state management, Clean Architecture principles, Supabase backend services, and location-based tracking.

---

## Overview

The Salesman Tracking App provides separate workflows for administrators and salesmen.

### Admin

Administrators can:

- Authenticate securely
- Manage salesmen
- View salesman information
- Monitor salesman activity
- View trip and visit information
- Access salesman location data

### Salesman

Salesmen can:

- Authenticate securely
- Start and manage trips
- Track their current location
- Record visits
- Upload visit-related media
- View their trip and visit information
- Continue working with appropriate handling of network connectivity

---

## Features

- User authentication
- Admin and salesman roles
- Salesman management
- Real-time location tracking
- Trip management
- Visit management
- GPS-based tracking
- Location permission handling
- Image and video uploads
- Supabase database integration
- Supabase Storage integration
- Supabase Edge Functions
- BLoC state management
- Dependency injection
- Clean Architecture-style project structure
- Repository pattern
- Offline/network-aware handling
- Android release support

---

## Tech Stack

### Frontend

- Flutter
- Dart
- BLoC
- Equatable

### Backend

- Supabase
- PostgreSQL
- Supabase Authentication
- Supabase Storage
- Supabase Edge Functions

### Device & Location

- Geolocator
- Permission Handler
- Image Picker
- Video Player

### Architecture & Utilities

- Clean Architecture
- Repository Pattern
- Dependency Injection
- GetIt
- FPDart
- Shared Preferences
- Flutter Map
- URL Launcher
- Intl

---

## Architecture

The project follows a Clean Architecture-inspired structure that separates presentation, business logic, domain models, and data access.

```text
lib/
├── app/
├── config/
├── core/
├── data/
│   ├── datasources/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── features/
│   ├── admin/
│   ├── auth/
│   ├── onboarding/
│   ├── salesman/
│   ├── salesman_details/
│   ├── trip/
│   └── visits/
├── init_dependencies.dart
└── main.dart