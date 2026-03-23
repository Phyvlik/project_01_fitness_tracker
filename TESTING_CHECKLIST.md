# Testing Checklist

Use this checklist before final submission and demo recording.

## Build and Startup
- [ ] flutter pub get completes successfully
- [ ] flutter analyze reports no blocking errors
- [ ] App launches on Android emulator/device
- [ ] Theme and navigation render correctly on startup

## Core Flow Validation
- [ ] Add workout with valid inputs
- [ ] Add workout with exercise details
- [ ] Save workout without exercises using confirmation dialog
- [ ] Invalid duration is rejected with helpful message
- [ ] Negative weight/invalid set-rep values are rejected

## Workout Log and Interactions
- [ ] Search by workout name works
- [ ] Intensity filters work (All/Low/Medium/High)
- [ ] Swipe-to-delete prompts confirmation dialog
- [ ] Workout detail bottom sheet opens and lists exercises

## Insights and Analytics
- [ ] Insights screen loads from bottom navigation
- [ ] Trend chart renders when data exists
- [ ] Empty-state message displays when no trend data
- [ ] Layout adapts in portrait and landscape

## Settings and Persistence
- [ ] Dark mode persists after app restart
- [ ] Weekly goal persists after app restart
- [ ] Weight unit persists after app restart
- [ ] Notifications toggle persists after app restart
- [ ] Export Data creates local JSON file and shows file path

## Data Layer
- [ ] SQLite tables created on first launch
- [ ] Starter exercises and quests are seeded
- [ ] Workout create/read/delete updates UI state correctly
- [ ] Quest progress increments after new workout

## Accessibility and UX
- [ ] Screen reader announces stat cards and workout cards clearly
- [ ] Buttons and tappable cards are reachable and usable
- [ ] Loading indicators and feedback snackbars appear at correct times

## Release Readiness
- [ ] flutter build apk --release succeeds
- [ ] app-release.apk installs and opens successfully
- [ ] README, ARCHITECTURE, and PROJECT_REPORT are up to date
- [ ] Selected presentation questions document is included
