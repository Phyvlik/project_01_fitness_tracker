# Architecture Decisions

## Overview
The app follows a feature-focused Flutter architecture centered around local-first storage.

- Presentation layer: Screens and reusable widgets under lib/screens and lib/widgets
- State layer: AppProvider (ChangeNotifier + Provider) under lib/providers
- Data layer: SQLite helper and model mapping under lib/db and lib/models

## Why Provider + ChangeNotifier
Provider was selected because the project scope is small-to-medium and requires shared reactive state across multiple screens.

Benefits:
- Lightweight setup and easy onboarding for team members
- Simple integration with Material widgets via Consumer and context.read
- Clear separation of UI and data-loading logic

## Why SQLite + SharedPreferences
Project requirements mandate local storage only (no cloud storage).

- SQLite stores relational app data: workouts, workout exercises, quests, and exercise library
- SharedPreferences stores simple user settings: dark mode, weekly goal, weight unit, notifications

This split keeps relational operations in SQL while preserving quick key-value preferences.

## Data Flow
1. User interacts with UI (screen/widget)
2. UI calls AppProvider method
3. AppProvider reads/writes through DatabaseHelper or SharedPreferences
4. AppProvider updates in-memory state and notifies listeners
5. UI rebuilds through Provider consumers

## Local AI Suggestion Design
AI behavior is implemented as rule-based on-device logic in AppProvider.

Inputs:
- Recent workout intensity history
- Consecutive high-intensity count
- Days since last workout

Output:
- Suggestion text and explainable reasoning string shown in UI

Why this approach:
- Fully offline and deterministic
- Easy to demo and explain in rubric Q&A
- No cloud API dependency

## Responsiveness Approach
- OrientationBuilder for adaptive Insights layout
- Flexible widgets and grid/list patterns for portrait/landscape
- Sliver-based Home screen for smooth scroll behavior

## Validation and Error Handling
- Form validation for required fields and numeric ranges
- Sanitization for text inputs before persistence
- Confirmation dialogs for destructive actions
- Snackbar feedback for success/failure flows

## Tradeoffs and Future Growth
Current architecture prioritizes simplicity and delivery speed for coursework.

Future upgrades:
- Repository layer between provider and database
- Feature-level providers for larger scale
- Structured domain/use-case separation if app complexity grows
