# Design Document: Rides and Children Re-implementation

## Overview

This design document outlines the re-implementation of the children and rides modules in a Flutter school bus tracking application. The implementation follows the BLoC/Cubit pattern for state management and the Repository pattern for data abstraction. The design focuses on restoring broken functionality while maintaining the existing UI structure and adding real-time tracking via WebSocket.

### Key Design Goals

1. **Clean Architecture**: Separate concerns between UI, business logic, and data layers
2. **Type Safety**: Use strongly-typed Dart models for all API responses
3. **Error Resilience**: Comprehensive error handling with user-friendly feedback
4. **Real-time Updates**: WebSocket integration for live bus tracking
5. **Maintainability**: Follow existing project conventions and patterns

## Architecture

### Layer Structure

The application follows a three-layer architecture:

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│  (Screens, Widgets, BLoC/Cubit)    │
└─────────────────────────────────────┘
              ↓ ↑
┌─────────────────────────────────────┐
│         Business Logic Layer        │
│     (Cubits, State Management)      │
└─────────────────────────────────────┘
              ↓ ↑
┌─────────────────────────────────────┐
│           Data Layer                │
│  (Repositories, API Services,       │
│   Models, WebSocket Service)        │
└─────────────────────────────────────┘
```

### Module Organization

```
lib/
├── features/
│   ├── children/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── child_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── children_repository.dart
│   │   │   └── services/
│   │   │       └── children_api_service.dart
│   │   ├── logic/
│   │   │   └── children_cubit.dart
│   │   └── ui/
│   │       ├── children_list_screen.dart
│   │       └── add_child_screen.dart
│   │
│   ├── rides/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   ├── ride_model.dart
│   │   │   │   ├── ride_occurrence_model.dart
│   │   │   │   └── ride_summary_model.dart
│   │   │   ├── repositories/
│   │   │   │   └── rides_repository.dart
│   │   │   └── services/
│   │   │       └── rides_api_service.dart
│   │   ├── logic/
│   │   │   ├── rides_cubit.dart
│   │   │   └── tracking_cubit.dart
│   │   └── ui/
│   │       ├── today_rides_screen.dart
│   │       ├── active_rides_screen.dart
│   │       ├── upcoming_ri