# 🏋️ Fitness Quest & Training Challenge Hub

A personalized fitness tracking application built with **Flutter** that combines personalized challenges and quests to guide users toward their workout goals. The app features customizable workout plans, progress tracking, SQLite-based local storage, and AI-powered suggestions for recovery and workout optimization.

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Features](#features)
- [Technologies Used](#technologies-used)
- [Installation Instructions](#installation-instructions)
- [Usage Guide](#usage-guide)
- [Documentation Checklist](#documentation-checklist)
- [API Notes](#api-notes)
- [Database Schema](#database-schema)
- [Known Issues](#known-issues)
- [Future Enhancements](#future-enhancements)
- [Team Members](#team-members)
- [License](#license)

## 🎯 Project Overview

**Fitness Tracker** solves a real student problem: keeping workouts focused and consistent. Many students struggle with:
- Lack of motivation and structured guidance
- Inconsistent workout tracking
- Unclear progress visibility
- Difficulty maintaining workout streaks

Our app tackles these challenges by:
- Creating **personalized workout quests** that evolve with user progress
- Providing **streak tracking** to maintain consistency
- Using **local AI suggestions** to recommend recovery time and new workouts
- **Encouraging participation** through achievements and quest completion

### Target Users

- College students looking to build sustainable fitness habits
- Fitness enthusiasts wanting organized workout tracking
- Anyone seeking guidance on recovery and workout optimization

## ✨ Features

### Core Features

#### 1. **Home Dashboard**
- Displays current workout streak (consecutive days with workouts)
- Shows weekly workout count vs. weekly goal
- Displays all active quests with progress
- Recent workout history (last 5 workouts)
- AI-powered workout suggestion card

#### 2. **Workout Logging (`AddWorkoutScreen`)**
- Create new workout sessions with:
  - Workout name and date
  - Duration (in minutes)
  - Intensity level (Low, Medium, High)
  - Optional notes
- Add multiple exercises per session with:
  - Exercise selection from library
  - Sets, reps, and weight tracking
  - Exercise-specific notes
- Form validation and error handling
- Auto-progression of active quests

#### 3. **Workout History (`WorkoutLogScreen`)**
- View complete workout history
- Search functionality by workout name
- Filter by intensity level
- Detailed view modal for each workout
- Swipe-to-delete functionality
- Exercise breakdown per workout

#### 4. **Quest System**
- Pre-seeded starter quests on first launch:
  - **First Step**: Complete 1 workout
  - **Week Warrior**: Complete 7 workouts in a week
  - **Iron Will**: Maintain a 14-day streak
  - **Strength Builder**: Log 50 total workouts
- Track quest progress with completion percentage
- Auto-progress active quests on new workout logging
- Visible progress indication and milestones

#### 5. **Settings Screen (`SettingsScreen`)**
- **Dark Mode**: Toggle between light and dark themes
- **Weekly Goal**: Set personal weekly workout target (3-7 workouts)
- **Weight Unit**: Toggle between lbs and kg
- **Notifications**: Enable/disable workout reminders
- **Data Export**: Export workouts and quests to local JSON file

#### 6. **Insights Screen (`InsightsScreen`)**
- Visual trend chart for last 14 days of workouts
- Performance summary cards (total workouts, streak, weekly progress, quest completion)
- Responsive layout adapts for portrait and landscape

#### 7. **Exercise Library**
- 30+ pre-seeded exercises across 8 categories:
  - Chest, Back, Legs, Shoulders, Arms, Core, Cardio, Full Body
- Exercise metadata: difficulty, equipment type, description
- Quick exercise selection during workout logging
- Advanced filters by category, difficulty, and equipment

#### 8. **AI-Powered Suggestions** (Rule-Based Local AI)
The app analyzes the last 5 workouts and provides intelligent suggestions:

- **Recovery Detection**: If 2+ consecutive high-intensity sessions → suggests "Rest day or Light Recovery Session"
- **Re-engagement**: If 3+ days since last workout → suggests "Medium Intensity Full-Body Workout"
- **Intensity Balancing**: If 3+ low-intensity sessions → suggests "High Intensity Strength Training"
- **Default Recommendation**: For consistent patterns → suggests "Maintain Your Momentum"

Each suggestion includes:
- **Explanation**: Shows why the recommendation was made
- **User Control**: Transparent logic helps users understand suggestions

### Additional Features

- **Streak Calculation**: Tracks consecutive days with workouts
- **Statistics**: Shows total workouts, weekly count, quest progress
- **Responsive Design**: Works on portrait and landscape
- **Input Validation**: Prevents invalid data entry
- **Data Persistence**: All data stored locally in SQLite

## 🛠 Technologies Used

### Framework & Language
- **Flutter**: 3.41.2
- **Dart**: 3.11.0

### Key Packages
| Package | Version | Purpose |
|---------|---------|---------|
| `sqflite` | ^2.3.3+1 | SQLite database for local data storage |
| `path_provider` | ^2.1.4 | File system paths for database location |
| `path` | ^1.9.0 | Path utilities for cross-platform compatibility |
| `shared_preferences` | ^2.3.2 | Key-value storage for user settings |
| `provider` | ^6.1.2 | State management and app-wide data access |
| `intl` | ^0.19.0 | Date/time formatting and localization |
| `fl_chart` | ^0.68.0 | Local workout trend chart visualization |

### Development Tools
- **VS Code**: Code editor
- **Android Studio**: Android emulation and testing
- **Git/GitHub**: Version control

## 📲 Installation Instructions

### Prerequisites
- Flutter SDK 3.40+ installed ([flutter.dev](https://flutter.dev))
- Android Studio or Android SDK for emulator
- Git installed on your machine

### Step 1: Clone the Repository
```bash
git clone https://github.com/Phyvlik/project_01_fitness_tracker.git
cd project_01_fitness_tracker
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Set Up Android Emulator or Device
- **Using Emulator**: Open Android Studio and start an emulator
- **Using Physical Device**: Connect via USB and enable developer mode

### Step 4: Run the App
```bash
flutter run
```

The app will compile and install on your emulator/device.

### Step 5: Build APK (Optional)
To create a release APK for testing:
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

## 📖 Usage Guide

### First Launch
1. The app initializes the SQLite database and seeds 30 exercises and 4 starter quests
2. You'll see the **Home Dashboard** with empty stats

### Logging Your First Workout

1. **Navigate to Workouts Tab** → Click "Log Workout" button
2. **Enter Workout Details**:
   - Workout name (e.g., "Chest Day", "Morning Run")
   - Select date (defaults to today)
   - Enter duration in minutes
   - Select intensity level
   - Add optional notes
3. **Add Exercises**:
   - Click "Add Exercise" button
   - Select from exercise library
   - Enter sets, reps, weight, optional notes
   - Click "Add" to add to session
   - Repeat for multiple exercises
4. **Save Workout**: Click "Save Workout" button
   - Data saves to SQLite
   - Quests auto-progress
   - Home dashboard updates

### Viewing Workout History

1. **Workouts Tab** shows all logged workouts
2. **Search**: Use search bar to find specific workouts
3. **Filter**: Click intensity chips to filter by Low/Medium/High
4. **Details**: Tap any workout card to see full details including exercise breakdown
5. **Delete**: Swipe left on a workout card to delete

### Managing Quests

1. **Home Tab** displays all quests with progress
2. Each quest shows:
   - Quest name and description
   - Progress bar and percentage
   - Current progress / target (e.g. 3/7 workouts)
   - Motivational milestone badges

### Customizing Settings

1. **Settings Tab** → Customize your experience:
   - **Dark Mode**: Toggle for eye comfort
   - **Weekly Goal**: 3-7 workouts per week
   - **Weight Unit**: Choose lbs or kg
   - **Notifications**: Enable reminders

### AI Suggestions

1. **Home Dashboard** shows AI suggestion card
2. Card displays:
   - Recommended workout/recovery action
   - Reasoning behind the suggestion
   - Updates after each logged workout

## ✅ Documentation Checklist

- [x] Clear README with project summary
- [x] Step-by-step setup instructions
- [x] Simple user guide for main app flows
- [x] Helpful comments in important code sections (see `lib/db/database_helper.dart`, `lib/providers/app_provider.dart`, and `lib/main.dart`)
- [x] API notes included (only where relevant)

## 🔌 API Notes

This project does **not** use any external web API.

- AI recommendations are local and rule-based (no network calls)
- Data is stored locally using SQLite and SharedPreferences
- Import/export uses local JSON files on device storage

## 🗄️ Database Schema

### Tables Overview

#### 1. `exercises` Table
```sql
CREATE TABLE exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,                      -- Exercise name
  category TEXT NOT NULL,                  -- Chest, Back, Legs, Shoulders, Arms, Core, Cardio, Full Body
  difficulty TEXT NOT NULL,                -- Beginner, Intermediate, Advanced
  equipment TEXT NOT NULL,                 -- Bodyweight, Dumbbells, Barbell, Machine, Cable, None
  description TEXT NOT NULL,               -- Exercise description/form tips
  is_custom INTEGER NOT NULL DEFAULT 0     -- 0 = predefined, 1 = user-created
);
```

#### 2. `workouts` Table
```sql
CREATE TABLE workouts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,                      -- Workout session name
  date TEXT NOT NULL,                      -- ISO 8601 format (yyyy-MM-dd)
  duration INTEGER NOT NULL,               -- Minutes
  notes TEXT NOT NULL DEFAULT '',          -- Optional user notes
  intensity TEXT NOT NULL,                 -- Low, Medium, High
  quest_id INTEGER                         -- Optional link to Quest
);
```

#### 3. `workout_exercises` Table
```sql
CREATE TABLE workout_exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  workout_id INTEGER NOT NULL,             -- Foreign key to workouts
  exercise_id INTEGER NOT NULL,            -- Foreign key to exercises
  exercise_name TEXT NOT NULL,             -- Cached exercise name
  sets INTEGER NOT NULL,                   -- Number of sets
  reps INTEGER NOT NULL,                   -- Reps per set
  weight REAL NOT NULL,                    -- Weight in user's preferred unit
  notes TEXT NOT NULL DEFAULT ''           -- Exercise-specific notes
);
```

#### 4. `quests` Table
```sql
CREATE TABLE quests (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,                      -- Quest name
  description TEXT NOT NULL,               -- Quest description
  target_workouts INTEGER NOT NULL,        -- Goal number of workouts
  current_progress INTEGER NOT NULL,       -- Current progress
  is_active INTEGER NOT NULL DEFAULT 1,    -- 1 = active, 0 = completed
  reward_description TEXT                  -- Optional reward text
);
```

### Data Relationships

```
exercises (1) ─── (*) workout_exercises
                        │
                        └─ (*) workouts ─ (1) quests
```

- Exercises are reusable across multiple workout sessions
- Each workout can contain multiple exercises
- Workouts can optionally link to a quest for progress tracking
- Quests track overall session progress

## ⚠️ Known Issues

1. **Limited AI Features**: AI suggestions use rule-based logic, not machine learning
2. **No Image Support**: Photo timeline feature mentioned in spec not yet implemented
3. **Notifications**: Notification preferences toggle in settings, but system notifications are not fully implemented

## 🚀 Future Enhancements

### High Priority
- [ ] **Photo Timeline**: Capture progress photos and create transformation timelines
- [ ] **Local Notifications**: Reminder notifications for scheduled workouts

### Medium Priority
- [ ] **Custom Quests**: Create user-defined quests with milestone rewards
- [ ] **Leaderboard**: Local leaderboard comparing user stats over time
- [ ] **Advanced AI**: Implement ML-based workout suggestions
- [ ] **Offline Analytics**: Detailed charts showing progress trends
- [ ] **Sound Effects**: Audio feedback for actions

### Low Priority
- [ ] **Multiple Users**: Support for multiple accounts per device
- [ ] **Wearable Integration**: Connect with fitness trackers
- [ ] **Social Features**: Share achievements with friends

## ⭐ Bonus Features Status

- [x] Data export/import functionality (JSON)
- [x] Dark mode theme switching
- [x] Advanced search with filters
- [x] Data visualization with charts
- [x] Offline-first architecture with local sync queue capability
- [ ] Biometric authentication (fingerprint/face)
- [ ] Custom camera integration for image capture
- [ ] Complete test suite with >80% coverage (graduate bonus)

## 👥 Team Members

| Name | Role | Contributions |
|------|------|---|
| Vivek Patel | Lead Developer | Navigation, Home Dashboard, Insights, Add Workout, Validation, SQLite Schema, Provider State, Settings, Export/Import, Offline Sync Queue |
| Edward Forrester | Teammate | Insights Engine, Data Visualization, Quest System, State Management, Metrics Logic |

## 📄 License

This project is licensed under the **MIT License** - see LICENSE.txt for details.

---

**Built for**: Mobile Application Development (MAD)  
**Course**: Undergrad  
**Institution**: Georgia State University  
**Status**: ✅ Functional MVP

For questions or feedback, open an issue on [GitHub](https://github.com/Phyvlik/project_01_fitness_tracker).
