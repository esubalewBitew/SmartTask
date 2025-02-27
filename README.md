# SmartTask

# SmartTask - Flutter Task Management App

SmartTask is a modern task management application built with Flutter, designed to help users organize and track their tasks efficiently.

## 🔥 Technical Overview

### Architecture
- **Pattern**: Clean Architecture with MVVM
- **State Management**: Bloc/Cubit for complex state management
- **Dependency Injection**: GetIt for service locator pattern
- **Local Storage**: Hive + SQLite (for offline capabilities)
- **Remote Storage**: Firebase Cloud Firestore
- **Real-time Updates**: Firebase Real-time Database + FCM
- **Authentication**: Firebase Auth


## 🌟 Features

- **Task Management**
  - Create, edit, and delete tasks
  - Set task priorities and due dates
  - Mark tasks as complete
  - Categorize tasks with labels
  - Able to set Reminder
  - Integrted to Calendar
  - Search and Filter by Date, name
  - Get Push Notification 

- **User Authentication**
  - Secure login and registration
  - Google Sign-in integration
  - Password reset functionality

- **Data Synchronization**
  - Real-time data sync with Firebase
  - Offline support(Hive For Local Storage)
  - Cross-device synchronization
 
- ** User Setting
   - Change Theme
   - Able to enable 2FA
   - Delete Account
 


- ** Anaytics
    - Track Task Accomplishiment and set rate for that
    -   
 
## Project Folder Structure

lib/
├── core/
│   ├── api/
│   │   ├── config/
│   │   │   ├── api_config.dart         # Base API configuration
│   │   │   └── environment_config.dart  # Environment specific config
│   │   ├── constants/
│   │   │   ├── api_constants.dart      # API URLs, timeouts, headers
│   │   │   └── api_endpoints.dart      # API endpoint paths
│   │   └── interceptors/
│   │       ├── auth_interceptor.dart   # Token handling
│   │       └── error_interceptor.dart  # Error handling
│   ├── common/
│   │   ├── animation/
│   │   ├── entities/
│   │   ├── pages/
│   │   ├── presentation/
│   │   │   ├── pages/
│   │   │   └── widgets/
│   │   └── widgets/                    
│   ├── Services/
│   │   ├── devices/
│   │   ├── navigation/
│   │   ├── storage/
│   │   ├── auth_guard
│   │   ├── injection_container
│   │   ├── notification_services
│   │   ├── route/
│   │   ├── secure_storage services
│   │   ├── api/
│   │   │   ├── pages/
│   │   │   └── widgets/
│   │   └── widgets/                    
│   ├── extensions/
│   └── res/                           # Resources
│   ├── theme
├── features/
│   ├── Auth/
|   ├       ├── data
|           ├── di
|           ├── domain
|           ├── presentation
|           
|
|    |
│   ├── Main/
│   │   ├── Home/
│   │   ├── Analytics/
│   │   ├── Profile/
│   │   ├── Tasks/
│   │   └── Workspace/
└── main.dart


### API Management

1. API Configuration (core/api/config/):
api_config.dart: 
Centralizes Dio client setup with:
   Base URL configuration
   Timeout settings
   Default headers
   Interceptor management

Environment Management
 - environment_config.dart

API Constants and Endpoints:
- api_constants.dart: 
   URLs, timeouts, headers
- api_endpoints.dart: 
    Organized endpoint paths
Interceptors:
auth_interceptor.dart: Token management
error_interceptor.dart: Error handling

Environment-based configuration
Centralized error handling
Token management
Request/Response interceptors

Template for Api Call

## Overview
A brief guide explaining how API communication works in SmartTask, using the Authentication flow as an example.

## Architecture Layers

    ### 1. API Client Layer
    - Centralized Dio client configuration
    - Base URL and timeout settings
    - Global interceptors for auth and logging
    - Common error handling
    
    ### 2. Repository Layer
    - Implements data access logic
    - Converts API responses to domain models
    - Handles caching and offline storage
    - Manages error handling and retries

    ### 3. State Management Layer (BLoC/Cubit)
    - Manages UI state based on API responses
    - Handles loading, success, and error states
    - Coordinates between UI and repository
    - Implements business logic
    
    ### 4. UI Layer
    - Consumes state from BLoC/Cubit
    - Shows loading indicators
    - Displays error messages
    - Updates UI based on API responses

    ### Authentication
    - Firebase Auth
    - Automatic token refresh(Firebase)
    - Secure token storage
    - Session management
    
    ### Error Handling
    - Network error recovery
    - Timeout management
    - User-friendly error messages
    
    ### Caching Strategy
    - Local data persistence
    - Offline-first approach
    - Background sync
    - Cache invalidation
    
    ## Security Measures
      - AES Encryption
       

    ### Request Security
    - SSL pinning(by Set minsdk version for future will be implemnt Approov)
    - Request signing
    - HTTPS enforcement
    - API key management
    
    ### Data Protection
    - Sensitive data encryption (AES)
    - Secure storage
    - Token encryption
    - Request/Response encryption

    ### Performance
    - Request timeout configuration
    - Connection pooling
    - Response caching
    - Request cancellation
    
    ### Code Organization
    - Clean architecture
    - Separation of concerns
    - Dependency injection
    - Modular design
    
    ### Testing
    - Unit tests for repositories
    - Mock API responses
    - Integration tests
    - Error scenario testing

    ### Authentication Flow
    1. User enters credentials
    2. API client sends request
    3. Server validates and returns token
    4. Token stored securely
    5. User navigated to home screen
    
    ### Error Handling Flow
    1. API request fails
    2. Error intercepted
    3. Appropriate error created
    4. UI updated with error message
    5. Retry mechanism if applicable


    ### Monitoring
    - Request logging
    - Error tracking
    - Performance monitoring
    - Usage analytics
    
    ### Updates
    - API version management
    - Backward compatibility
    - Documentation updates
    - Client updates

  # Real-Time Collaboration Implementation


Real-time collaboration in SmartTask enables multiple users to work simultaneously on tasks within team workspaces, providing instant updates and live user presence.


### 1. Real-Time Task Updates
- Instant synchronization of task changes across all connected devices(bY Using Firebase Firestore)
- Live updates for task creation, editing, and deletion
- Conflict resolution for simultaneous edits
- Optimistic UI updates with server validation

### 2. User Presence System
- "Currently viewing" indicators on tasks
- Push Notification Invoked
- Active user list in workspace

### 3. Collaborative Features
- Real-time task comments and discussions
- Live task assignment notifications(Push Notification)
- Instant status change broadcasts
- Collaborative task editing with locks


### Firebase Integration
- Firestore for real-time data sync
- Cloud Functions for server-side logic
- Firebase Authentication for user management
- Security Rules for access control


### State Management
- Used Bloc/Cupit
- Optimistic updates for better UX
- Local state synchronization
- Conflict resolution handling
- Cache management

### Data Optimization
- Selective data subscription
- Batch updates for multiple changes
- Delta updates for minimal data transfer
- Pagination for large datasets

### Network Efficiency
- Connection pooling
- Message compression
- Throttling for rapid updates
- Bandwidth optimization


### Visual Indicators
- Color-coded user presence
- Activity indicators
- Progress animations
- Status change notifications

### Collaboration Features
- User avatars on active tasks
- Edit history tracking
- Change notifications
- Activity timeline

## Security Measures

    ### Access Control
    - Workspace-level permissions
    - User role management
    - Action-based restrictions
    - Data validation

    ### Connection Management
    - Automatic reconnection
    - Offline mode support
    - Data synchronization
    - Conflict resolution
    
    ### Recovery Procedures
    - State recovery after disconnection
    - Data consistency checks
    - Error notifications
    - Fallback mechanisms

##  Code Quality Guidelines

## Table of Contents
- [Code Quality Tools](#code-quality-tools)
- [Setup Instructions](#setup-instructions)
- [CI/CD Integration](#ci-cd-integration)
- [Code Quality Standards](#code-quality-standards)
- [Running Tests Locally](#running-tests-locally)

## Code Quality Tools

### 1. Code Formatting
- **dart format** - Built-in Dart formatter
- **flutter_lints** - Official Flutter lint rules
- **custom_lint** - Custom lint rules for project-specific standards

### 2. Static Analysis
- **analyzer** - Dart's static analyzer
- **dart_code_metrics** - Additional static analysis rules
- **sonarqube** - Comprehensive code quality platform

### 3. Testing Tools
- **flutter_test** - Unit and widget testing
- **integration_test** - Integration testing
- **mockito** - Mocking framework for tests

## Setup Instructions

  Add neccessary dependencies to `pubspec.yaml`:
  Should be create Firebase Account

## Code Quality Standards

### 1. Code Style
- Follow official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Maximum line length: 80 characters
- Use meaningful variable and function names
- Document public APIs

### 2. Architecture
- Follow Clean Architecture principles(MVVM)
- Maintain separation of concerns
- Use dependency injection
- Follow SOLID principles

### 3. Testing Requirements
- Minimum test coverage: 80%
- Unit tests for business logic
- Widget tests for UI components
- Integration tests for critical flows

## Running Tests Locally

. Format code:
  dart format .
    Run static analysis:
    Run tests with coverage





Widget Layer

The widget layer is designed to enhance reusability and maintain consistency across the application. It includes:

Reusable components – Modular widgets to avoid duplication.
Consistent styling – Unified theme and design patterns.
Form management – Efficient handling of user inputs.
Custom animations – Smooth and interactive user experiences.



## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.19.0 or higher)
- Dart SDK
- Android Studio
- VS Code/ other IDE
- XCODE /for ios setup
- Git
- Firebase account

### Installation

1. Clone the repository:

[https://github.com/esubalewBitew/SmartTask]

2. Navigate to project directory
   cd smarttask

3.Install dependencies
  flutter pub get

4. Setup Firebase
   flutterfire config

  

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
