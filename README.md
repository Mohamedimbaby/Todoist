# TaskTime — Kanban Time-Tracking (Flutter MVP)

TaskTime is a mobile-first Flutter MVP that provides a Kanban board and per-task time tracking with **offline-first** behavior and optional sync to Todoist.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Coverage](https://img.shields.io/badge/Coverage-90%25-brightgreen)

## Key Choices

| Feature | Choice |
|---------|--------|
| Platforms | iOS & Android |
| Local DB | **Hive** |
| State Management | **BLoC (Cubit)** |
| Offline Support | Offline-first with sync queue |
| Test Coverage | **90%** target |
| CI/CD | **Codemagic** |
| License | **MIT (public repo)** |

---

## Demo

*(Add demo GIF/video here)*

---

## Features (MVP)

- ✅ Kanban board with three columns: To Do, In Progress, Done
- ✅ Create / edit / move tasks between columns (local)
- ✅ Per-task timer: start / stop / persists across restarts
- ✅ Completed tasks history with tracked time and completion timestamp
- ✅ Comments per task (local, syncable)
- ✅ Optional Todoist sync (user supplies Test Token)
- ✅ Offline sync queue with manual "Sync now"
- ✅ Themes: light/dark; ready for more themes
- ✅ Multi-language support (English + Spanish placeholder)

---

## Project Structure

```
/lib
├── core/           # App-wide config, errors, constants, themes
│   ├── constants/
│   ├── errors/
│   └── theme/
├── data/           # Hive boxes, DTOs, Todoist provider, mappers
│   ├── models/
│   ├── providers/
│   └── repositories/
├── domain/         # Entities, Repository abstracts, UseCases
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/   # BLoCs/Cubits, UI screens, widgets
│   ├── cubits/
│   ├── pages/
│   └── widgets/
├── di/             # Dependency injection (get_it)
└── utils/          # Helpers (time formatting, validators)
```

---

## Setup (Developer)

### 1. Clone

```bash
git clone <repo-url>
cd tasktime
```

### 2. Install Dependencies

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Environment Configuration

Todoist sync is optional. If you want to enable it:

**Option A: Set in app settings**
- Open app → Settings → Sync
- Enter your Todoist Test Token

**Option B: For CI/CD (Codemagic)**
- Set `TODOIST_TEST_TOKEN` as a secure environment variable

### 4. Run

```bash
flutter run
```

### 5. Run Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Check coverage threshold (90%)
./scripts/check_coverage.sh 90
```

---

## Hive Notes

### Boxes

| Box Name | Purpose |
|----------|---------|
| `tasks_box` | Task entities |
| `timers_box` | Timer state per task |
| `comments_box` | Task comments |
| `history_box` | Completed task history |
| `sync_queue_box` | Pending sync actions |
| `settings_box` | App settings (theme, language) |
| `projects_box` | Todoist projects cache |

### Timer Persistence

Running timers are persisted using:
- `startTimestamp`: When the timer was started
- `accumulatedSeconds`: Previously tracked time

On app restart, elapsed time is calculated from `startTimestamp`.

---

## Todoist Sync & Mapping

### Configuration

1. Navigate to **Settings → Sync**
2. Enter your Todoist Test Token
3. Tap "Connect"

### Sync Behavior

- Local columns are used by default
- Actions are queued when offline
- Manual "Sync Now" button triggers sync
- Conflicts resolved via **last-writer-wins**

### API Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/projects` | GET | Fetch projects |
| `/projects` | POST | Create project |
| `/projects/{id}` | DELETE | Delete project |
| `/tasks` | POST | Create task |
| `/tasks/{id}` | POST | Update task |
| `/tasks/{id}/close` | POST | Complete task |
| `/tasks/{id}` | DELETE | Delete task |

**API Documentation**: [Todoist REST API v2](https://developer.todoist.com/rest/v2/)

---

## Codemagic CI/CD

### Workflow Overview

1. **Get packages**: `flutter pub get`
2. **Generate code**: `build_runner`
3. **Static analysis**: `flutter analyze`
4. **Run tests**: `flutter test --coverage`
5. **Coverage check**: Fail if < 90%
6. **Build artifacts**: APK & IPA

### Setup

1. Connect repository to Codemagic
2. Add environment variables:
   - `TODOIST_TEST_TOKEN` (if testing sync)
3. Configure code signing for iOS (if publishing)

### Coverage Enforcement

```bash
# The CI will fail if coverage drops below 90%
./scripts/check_coverage.sh 90
```

---

## Testing Strategy

| Type | Coverage |
|------|----------|
| **Unit Tests** | UseCases, Entities, Utilities |
| **BLoC Tests** | TaskCubit, TimerCubit, SyncCubit |
| **Widget Tests** | KanbanBoard, TaskCard, Dialogs |
| **Integration Tests** | Offline create → Sync flow |

### Running Specific Tests

```bash
# Unit tests
flutter test test/domain/

# Cubit tests
flutter test test/presentation/cubits/

# Widget tests
flutter test test/widget_test.dart
```

---

## Architecture Decisions

### 1. Offline-First

All data is stored locally in Hive first. Sync happens on-demand to Todoist.

### 2. Single Concurrent Timer

Only one timer can run at a time. Starting a new timer automatically stops any running timer.

### 3. Local Columns by Default

Kanban columns are local concepts. Optional mapping to Todoist Projects/Sections when sync is enabled.

### 4. Last-Writer-Wins Conflict Resolution

Simple and pragmatic conflict resolution strategy.

### 5. Clean Architecture

Strict separation between:
- **Domain**: Business logic (entities, use cases)
- **Data**: Persistence and API (repositories, models)
- **Presentation**: UI (cubits, widgets, pages)

---

## How to Contribute

1. Open issues for bugs/features
2. Follow existing architecture
3. Add tests for new code
4. Keep PRs small and focused
5. Maintain 90% coverage

---

## Roadmap

- [x] Additional themes
- [x] More languages
- [x] Team collaboration
- [x] Add Projects
- [x] Add Tasks
- [x] Move Tasks to any status
- [x] Timers
- [x] History
- [x] Comments add/delete
- [x] Offline first for all APIs
- [x] CICD with code magic  -> file ready to be integrated

---

## License

MIT License - see [LICENSE](LICENSE) file.

---

## Acknowledgments

- [Flutter](https://flutter.dev)
- [Hive](https://pub.dev/packages/hive)
- [flutter_bloc](https://pub.dev/packages/flutter_bloc)
- [Todoist API](https://developer.todoist.com)
