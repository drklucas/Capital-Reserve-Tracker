# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added - 2025-01-19

#### Task Management System
- Task entity with task-based progress tracking for goals
- Task CRUD operations (Create, Read, Update, Delete)
- Task repository and use cases following Clean Architecture
- Task remote data source with Firestore integration
- TaskProvider for state management
- Drag-and-drop task reordering with ReorderableListView
- Task completion toggle functionality
- Automatic order assignment for new tasks

#### Goal Management Enhancements
- Removed monetary tracking from goals (targetAmount, currentAmount)
- Progress calculation based on days elapsed vs total days
- Days remaining calculation (includes current day)
- Goal status management (active, completed, paused, cancelled)
- Real-time goal updates with Firestore streams
- Goal filtering by status in GoalProvider
- Transaction association with goals

#### HomeScreen Modernization
- Complete UI redesign with dark gradient theme
- Background gradient: Navy dark (#1a1a2e → #16213e → #0f3460)
- Animated greeting section with fade and slide transitions
- Split navigation cards:
  - Capital Reserve card (purple gradient) → navigates to transactions
  - Goals card (blue gradient) → navigates to goals
- Stats overview card with period filters:
  - Today, Week (last 7 days), Month views
  - Real-time transaction totals (Income, Expenses, Balance, Transaction count)
  - Dark gradient background (#2d3561 → #1f2544)
- Active goals section showing up to 3 goals with:
  - Individual goal cards with vibrant gradients
  - Days remaining badge
  - Progress bar based on time elapsed
  - Sequential entrance animations
- Quick actions grid with harmonized color palette
- Floating action button with green gradient and glow effect

#### UI/UX Improvements
- All titles and text changed to white for dark theme compatibility
- Period selector tabs with glass-morphism effect
- Stat items with semi-transparent backgrounds
- Consistent color palette across all components:
  - Capital: #5A67D8 → #6B46C1 (Purple/Indigo)
  - Goals: #3B82F6 → #06B6D4 (Blue/Cyan)
  - Transactions: #10B981 → #059669 (Green)
  - Analytics: #8B5CF6 → #6B46C1 (Purple)
  - Goal cards: Pink/Purple, Purple/Blue, Orange/Red variations
- Removed currency display from goals listing
- Enhanced animations throughout the app

#### Authentication Fixes
- Fixed user display name persistence on app restart
- Added explicit `notifyListeners()` in auth state change stream
- Improved fallback display name logic with loading state
- User email/name now persists correctly across app sessions

#### Data Layer Improvements
- Enhanced task repository with batch update operations
- Task query optimization (orderBy createdAt with in-memory sorting by order)
- Goal provider now tracks task statistics for active goals
- New getters: totalTasksForActiveGoals, completedTasksForActiveGoals, activeGoalsTaskProgress
- Transaction type checking using isIncome/isExpense getters
- Fixed transaction balance calculations

### Changed
- Goal entity structure (removed financial fields, added task-based progress)
- Goal creation/update use cases (removed amount-related parameters)
- Transaction filtering logic (fixed period-based filters)
- HomeScreen structure (from StatelessWidget to StatefulWidget with animations)
- Color scheme to dark theme with vibrant accents
- Navigation flow with split-action cards

### Fixed
- Task display issue (tasks not appearing in goal detail)
- Days calculation consistency (daysRemaining now includes current day)
- Transaction period filtering (Week filter now correctly shows last 7 days)
- User authentication persistence across app restarts
- Transaction type determination (using type field instead of amount sign)
- Missing userId parameter in watchTransactions
- Type mismatch errors (double/int conversions)

### Technical Improvements
- Added TaskRemoteDataSource dependency to GoalProvider
- Enhanced Firestore security rules for goals collection
- Improved error handling in task operations
- Optimistic updates for task reordering
- Better state management with Provider notifications

## [0.2.0] - Sprint 2 Complete

### Major Features
- Complete goal management system
- Task-based progress tracking
- Modern dark theme UI
- Real-time statistics dashboard
- Period-based analytics

### Files Created
- `lib/domain/entities/task_entity.dart`
- `lib/data/models/task_model.dart`
- `lib/domain/repositories/task_repository.dart`
- `lib/data/repositories/task_repository_impl.dart`
- `lib/data/datasources/task_remote_datasource.dart`
- `lib/domain/usecases/task/create_task_usecase.dart`
- `lib/domain/usecases/task/update_task_usecase.dart`
- `lib/domain/usecases/task/delete_task_usecase.dart`
- `lib/domain/usecases/task/get_tasks_usecase.dart`
- `lib/domain/usecases/task/toggle_task_usecase.dart`
- `lib/presentation/providers/task_provider.dart`

### Files Modified
- `lib/presentation/screens/home/home_screen.dart` - Complete redesign
- `lib/presentation/screens/goals/goal_detail_screen.dart` - Task management integration
- `lib/presentation/screens/goals/goals_screen.dart` - Removed currency display
- `lib/presentation/screens/goals/add_goal_screen.dart` - Removed amount fields
- `lib/presentation/providers/goal_provider.dart` - Added task statistics
- `lib/presentation/providers/auth_provider.dart` - Fixed persistence
- `lib/domain/entities/goal_entity.dart` - Removed financial fields
- `lib/main.dart` - Added task provider dependencies
- Multiple use cases updated to remove amount parameters

## [0.1.0] - Sprint 1 Complete

### Added
- User authentication (email/password)
- Clean Architecture setup
- Transaction management (CRUD)
- 15 transaction categories
- Real-time Firestore synchronization
- Firebase integration
- Security setup for public repository

---

**Note**: This project follows Clean Architecture principles and uses Firebase for backend services.
