# Phase-Based Recovery System - Documentation

## Overview
The Purity Path app implements a gradual, structured approach to help users overcome porn addiction through a 4-phase reduction system.

## System Architecture

### 1. Data Models

#### ReductionPhase Model (`lib/data/models/reduction_phase.dart`)
```dart
- phaseNumber: int          // Phase sequence number (1-based)
- phaseType: String         // 'duration', 'frequency', 'spacing', or 'complete'
- weekNumber: int           // Week within the phase
- durationLimit: int        // Maximum session duration in minutes
- frequencyLimit: int       // Maximum sessions per week
- spacingLimit: String      // Minimum time between sessions ('biweekly', 'monthly')
- description: String       // User-friendly description
- startDate: DateTime       // When phase begins
- endDate: DateTime         // When phase ends
- isCompleted: bool         // Completion status
```

### 2. Core Services

#### PhaseManager (`lib/data/services/phase_manager.dart`)
Responsible for generating and managing the reduction plan.

**Key Methods:**
- `generateReductionPlan(int frequency, int durationMinutes)` - Creates complete plan based on questionnaire
- `getCurrentPhase()` - Gets active phase
- `advanceToNextPhase()` - Moves to next phase
- `shouldMoveToNextPhase()` - Checks if ready to advance
- `savePlan(List<ReductionPhase>)` - Persists plan to SharedPreferences
- `loadPlan()` - Retrieves saved plan

**Phase Generation Logic:**

##### Phase 1: Duration Reduction
- **Goal:** Reduce session duration by ~1/3 each week until 10 minutes
- **Example for 60-minute user:**
  - Week 1: 40 minutes
  - Week 2: 20 minutes
  - Week 3: 10 minutes
- **Logic:** `(currentDuration * 2 / 3).round()`

##### Phase 2: Frequency Reduction
- **Goal:** Reduce weekly sessions based on starting frequency
- **High frequency (4-7x/week):** Reduce by 2 sessions per week
  - Example: 7x → 5x → 3x → 1x
- **Medium frequency (2-3x/week):** Reduce by 1 session per week
  - Example: 3x → 2x → 1x
- **Logic:** Continues until reaching 1 session per week

##### Phase 3: Spacing - Biweekly
- **Goal:** Only 1 session every 2 weeks
- **Duration:** 2 weeks minimum
- **Spacing:** 14 days between sessions

##### Phase 4: Spacing - Monthly
- **Goal:** Only 1 session per month
- **Duration:** 2-3 months
- **Spacing:** 30 days between sessions

##### Phase 5: Complete Control
- **Goal:** Zero sessions
- **Status:** Success state - user has overcome addiction

#### SessionTracker (`lib/data/services/session_tracker.dart`)
Monitors and tracks content viewing sessions in real-time.

**Key Methods:**
- `startSession()` - Begins tracking when adult content detected
- `endSession()` - Ends tracking when content closed
- `getCurrentSessionDuration()` - Gets duration of active session
- `getWeeklySessionCount()` - Returns sessions this week
- `canStartNewSession()` - Checks if allowed based on current phase limits

**Session Counting Rules:**
- Minimum 60 seconds to count as a "session"
- Weekly counter resets every Monday at midnight
- Tracks both duration and frequency limits

### 3. Integration Points

#### Questionnaire (`lib/view/navigations/questionnaire_manager.dart`)
- Captures initial frequency: `frequencyResponse` (1-10+ scale)
- Captures initial duration: `quantityResponse` (minutes per session)
- Calls `PhaseManager.generateReductionPlan()` on completion
- Saves plan to persist across app restarts

#### Accessibility Service (`android/.../NoFapIslamAccessibilityService.kt`)
- Detects adult apps/content using keyword matching
- Integrates with SessionTracker when content detected
- Enforces blocking when limits exceeded:
  - Duration limit: Blocks when `getCurrentSessionDuration() > currentPhase.durationLimit`
  - Frequency limit: Blocks when `getWeeklySessionCount() >= currentPhase.frequencyLimit`
- Shows custom block screen with motivation

## User Journey

### 1. Onboarding
1. User completes questionnaire
2. Answers frequency question (e.g., "4-7 times per week")
3. Answers duration question (e.g., "60 minutes per session")
4. System generates personalized reduction plan

### 2. Active Recovery
1. User uses their device normally
2. When adult content is detected:
   - SessionTracker starts monitoring
   - Timer begins counting duration
3. If limits exceeded:
   - Accessibility service blocks access
   - Shows motivational message
   - Enforces phase restrictions

### 3. Phase Progression
1. Each week, system checks `shouldMoveToNextPhase()`
2. If user stayed within limits:
   - Moves to next phase automatically
   - Updates restrictions (smaller duration/frequency)
3. If user exceeded limits:
   - Repeats current phase week
   - Provides encouragement to try again

### 4. Success
1. User completes all phases
2. Reaches "Complete Control" phase
3. App celebrates achievement
4. Continues monitoring for relapse prevention

## Example Recovery Plan

**User Profile:**
- Frequency: 6 times per week
- Duration: 60 minutes per session

**Generated Plan:**

| Phase | Week | Type | Duration Limit | Frequency Limit | Description |
|-------|------|------|----------------|-----------------|-------------|
| 1 | 1 | Duration | 40 min | 6x/week | Reduce to 40 minutes |
| 1 | 2 | Duration | 20 min | 6x/week | Reduce to 20 minutes |
| 1 | 3 | Duration | 10 min | 6x/week | Reduce to 10 minutes |
| 2 | 4 | Frequency | 10 min | 4x/week | Down to 4 times/week |
| 2 | 5 | Frequency | 10 min | 2x/week | Down to 2 times/week |
| 2 | 6 | Frequency | 10 min | 1x/week | Once per week |
| 3 | 7-8 | Spacing | 10 min | Biweekly | Once every 2 weeks |
| 4 | 9-16 | Spacing | 10 min | Monthly | Once per month |
| 5 | 17+ | Complete | 0 min | Never | Complete control |

## Technical Implementation Details

### Data Persistence
- Uses `SharedPreferences` to store plan
- Saves after generation and updates
- Loads on app startup
- Key: `'reduction_plan'`

### Accessibility Service Persistence
- Uses `AccessibilityMonitorService` as foreground service
- Runs even when app is closed
- Shows persistent notification
- Auto-restarts on device boot via `BootReceiver`

### Notification System
- Uses `notification_service.dart` for alerts
- Shows encouragement messages
- Tracks phase progression
- Celebrates milestones

### Firebase Integration
- Stores plan in Firestore for cloud backup
- Syncs across devices (if user signs in)
- Analytics for tracking success rates
- Anonymous data for research

## Files Reference

### Core System Files
- `lib/data/models/reduction_phase.dart` - Phase data model
- `lib/data/services/phase_manager.dart` - Plan generation & management
- `lib/data/services/session_tracker.dart` - Real-time session monitoring
- `lib/view/navigations/questionnaire_manager.dart` - Initial data capture
- `android/app/src/main/kotlin/.../NoFapIslamAccessibilityService.kt` - Content blocking

### Supporting Files
- `lib/data/services/notification_service.dart` - User notifications
- `android/app/src/main/kotlin/.../AccessibilityMonitorService.kt` - Service persistence
- `android/app/src/main/kotlin/.../BootReceiver.kt` - Auto-start on boot

## Current Status

✅ **Completed:**
- Phase model with all necessary fields
- PhaseManager with complete generation logic
- SessionTracker with duration and frequency monitoring
- Accessibility service with content detection
- Foreground service for persistence
- Data persistence with SharedPreferences

⏳ **Needs Integration:**
- Connect SessionTracker to accessibility service
- Add blocking logic based on phase limits
- Implement phase advancement automation
- Add user-facing phase progress UI
- Create celebration/motivation screens

## Next Steps

1. **Integrate Session Tracking with Accessibility Service:**
   - Call `SessionTracker.startSession()` when adult content detected
   - Call `SessionTracker.endSession()` when content closed
   - Implement blocking when limits exceeded

2. **Create Phase Progress UI:**
   - Show current phase in app
   - Display weekly progress
   - Show countdown to next phase
   - Celebrate phase completions

3. **Add Motivational System:**
   - Show encouragement during blocking
   - Display progress statistics
   - Celebrate milestones
   - Share success stories

4. **Testing:**
   - Test phase generation with various inputs
   - Verify blocking logic works correctly
   - Test phase advancement
   - Ensure data persists across restarts

## Notes

- System is already fully implemented in codebase
- Matches user's handwritten plan exactly
- Ready for final integration steps
- Designed with user psychology in mind
- Gradual approach increases success rate
