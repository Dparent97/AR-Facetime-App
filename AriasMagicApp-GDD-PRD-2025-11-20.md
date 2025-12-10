# Aria's Magic SharePlay App - GDD/PRD (2025-11-20)

## Table of Contents
- [1. Feature Inventory](#1-feature-inventory)
  - [1.1 Implemented (Working)](#11-implemented-working)
  - [1.2 Partially Implemented (Broken/Incomplete)](#12-partially-implemented-brokenincomplete)
  - [1.3 Placeholder/Stub](#13-placeholderstub)
- [2. Product Overview](#2-product-overview)
- [3. Technical Architecture](#3-technical-architecture)
  - [3.1 Current Architecture (As-Is)](#31-current-architecture-as-is)
  - [3.2 Proposed Architecture (Rebuild Recommendation)](#32-proposed-architecture-rebuild-recommendation)
  - [3.3 System Boundaries](#33-system-boundaries)
  - [3.4 Data Flow Diagrams (Textual)](#34-data-flow-diagrams-textual)
- [4. Feature Specifications](#4-feature-specifications)
- [5. Current State Assessment](#5-current-state-assessment)
- [6. Rebuild vs. Repair Analysis](#6-rebuild-vs-repair-analysis)
- [7. Migration Strategy](#7-migration-strategy)
- [8. Open Questions](#8-open-questions)

## 1. Feature Inventory
### 1.1 Implemented (Working)
- **AR session bootstrap & gesture input**
  - **State:** ~70% (gestures and session wiring present; relies on missing view-model hooks for camera updates)
  - **Files:** `Views/AR/MagicARView.swift`
  - **Dependencies:** ARKit, RealityKit, `CharacterViewModel`, `FaceTrackingService`, `HapticManager`.
- **Character spawning & basic transforms**
  - **State:** ~70% (spawn, move, scale, remove, simple animations)
  - **Files:** `Models/Character.swift`, `ViewModels/CharacterViewModel.swift`
  - **Dependencies:** RealityKit, `HapticManager`, `AudioService`, `SharePlayService` (for sync).
- **Manual action triggers (wave/dance/twirl/jump/sparkle)**
  - **State:** ~60% (animations stubbed with transforms; audio hooks present but silent)
  - **Files:** `Models/Character.swift`, `ViewModels/CharacterViewModel.swift`
  - **Dependencies:** `AudioService` (future), `SharePlayService` (broadcasts).
- **Particle effects (basic + enhanced implementations)**
  - **State:** ~65% (working local particle entities; enhanced RealityKit particle presets)
  - **Files:** `Models/MagicEffect.swift`, `Effects/EnhancedParticleEffects.swift`
  - **Dependencies:** RealityKit, `AudioService` via `ParticleEffectManager`.
- **Face expression handling (smile/eyebrow/mouth-open)**
  - **State:** ~60% (expression detection and callbacks; relies on AR face tracking availability)
  - **Files:** `Services/FaceTrackingService.swift`, `ViewModels/CharacterViewModel.swift`
  - **Dependencies:** ARKit blend shapes, `HapticManager`, `MagicARView` coordinator.
- **Audio service scaffolding (SFX + mic monitoring for clap detection)**
  - **State:** ~50% (engine setup, SFX enums, mic monitoring for loud noises wired to jump action)
  - **Files:** `Services/AudioService.swift`, `ViewModels/CharacterViewModel.swift`
  - **Dependencies:** AVFoundation, Combine.
- **Error handling & logging plumbing**
  - **State:** ~50% (error alerts in `ContentView`, logging service hooks)
  - **Files:** `Views/ContentView.swift`, `Services/ErrorLoggingService.swift`
  - **Dependencies:** SwiftUI alerts, custom `AppError` domain.

### 1.2 Partially Implemented (Broken/Incomplete)
- **SharePlay synchronization layer**
  - **What's there:** Activity definition, session setup, messenger wiring, send/receive pipelines with throttling.
  - **Missing/Blocking:** Unresolved merge conflicts in `SyncMessage`, mixed schemas (legacy vs new), duplicate delegate protocols, inconsistent effect typing, lack of validation, undefined `CharacterSyncState` owner semantics.
  - **Files:** `Services/SharePlayService.swift`.
- **Character model protocol conformance**
  - **What's there:** `AnimatableCharacter` mentions, model entity setup, action methods.
  - **Missing/Blocking:** Duplicate `characterType` property (stored + computed) referencing undefined `type`, risking compilation failure; legacy overload duplication.
  - **Files:** `Models/Character.swift`.
- **Hide-and-seek camera awareness**
  - **What's there:** AR session delegate calls `updateCameraPosition`.
  - **Missing/Blocking:** `CharacterViewModel` lacks `updateCameraPosition`, so call site fails to compile / runtime.
  - **Files:** `Views/AR/MagicARView.swift`, `ViewModels/CharacterViewModel.swift`.
- **Action/gesture persistence to SharePlay**
  - **What's there:** Gesture handlers move/scale entities locally; SharePlay sends updates on view-model calls.
  - **Missing/Blocking:** Coordinator gesture handlers mutate `ModelEntity` directly without informing view model, so remote peers never receive move/scale updates; selection state not reflected in model.
  - **Files:** `Views/AR/MagicARView.swift`, `ViewModels/CharacterViewModel.swift`.
- **Audio playback for actions/effects**
  - **What's there:** Audio engine bootstrapped; action/effect calls prepared.
  - **Missing/Blocking:** No asset loading, no actual playback invocations in Character actions, no effect sound files declared; error handling minimal.
  - **Files:** `Services/AudioService.swift`, `Models/Character.swift`, `Effects/EnhancedParticleEffects.swift`.
- **Settings & accessibility controls**
  - **What's there:** Settings sheet trigger in `ContentView`; haptic respect flags.
  - **Missing/Blocking:** `SettingsView` implementation, persistence of toggles, binding to services.
  - **Files:** `Views/ContentView.swift`, `Services/HapticManager.swift` (settings flags unused).

### 1.3 Placeholder/Stub
- **3D character assets and skeletal animations**
  - **Intent:** Replace colored cubes with princess models and real animations.
  - **Files:** `Models/Character.swift` (box mesh placeholder), README roadmap.
- **Magic effects using production particle systems**
  - **Intent:** Swap handcrafted particle entities with RealityKit particle emitters tied to characters.
  - **Files:** `Models/MagicEffect.swift` (simple entities), `Effects/EnhancedParticleEffects.swift` (ready-made emitters not yet integrated with scene), `ParticleEffectManager` not referenced from AR view.
- **SharePlay protocol finalization**
  - **Intent:** Single schema for spawn/update/remove/action/effect with validation and backward compatibility plan.
  - **Files:** `Services/SharePlayService.swift` (conflict markers and dual schemas).
- **Onboarding/tutorial & settings UI**
  - **Intent:** Intro flow and settings overlay per README.
  - **Files:** `Views/ContentView.swift` references `OnboardingView`/`SettingsView`, but implementations not present in repo.

## 2. Product Overview
### Vision Statement
Create a delightful, child-friendly AR companion that lets kids and parents share playful princess characters, gestures, and magic effects together over FaceTime/SharePlay.

### Core Gameplay Loop
1. Join FaceTime + start SharePlay session.
2. Spawn a character in AR space; move/scale it via gestures.
3. Trigger animations via UI buttons or face expressions (smile/wave/jump) and magic effects (sparkles/snow/bubbles).
4. Synced state mirrors across participants; audio/haptics reinforce interactions.

### Target Platform
- iOS 17+ with TrueDepth camera and ARKit; multiuser via SharePlay (GroupActivities).

### Key Differentiators
- Face-expression-driven magic triggers for kids.
- Synchronous AR play across callers (SharePlay).
- Low-friction gestures (tap/drag/pinch) plus tactile haptics.

## 3. Technical Architecture
### 3.1 Current Architecture (As-Is)
- **UI Layer:** `ContentView` orchestrates AR view and overlays (pickers, action buttons, onboarding/settings sheets). Alerts surfaced via `AppError` -> `ErrorAlert`.
- **AR Layer:** `MagicARView` (UIViewRepresentable) sets up ARView, gestures, anchors, session delegate, and coordinates face tracking.
- **Domain Models:** `Character`, `MagicEffect`, simple enums for actions/effects. Placeholder mesh for characters.
- **ViewModel:** `CharacterViewModel` owns characters/effects, routes actions to models, mirrors to SharePlay, and responds to face-tracking + audio events.
- **Services:**
  - `SharePlayService` for GroupActivities messaging (conflicted schema).
  - `FaceTrackingService` to convert ARFaceAnchor blend shapes to expressions.
  - `AudioService` for SFX + mic monitoring; `HapticManager` for feedback; `ErrorLoggingService` stub.
- **Assets/Resources:** None for 3D/audio; placeholders only.

### 3.2 Proposed Architecture (Rebuild Recommendation)
- **Modular layers:**
  - Core domain (`Character`, `MagicEffect`, `CharacterStore`) decoupled from RealityKit types via protocols.
  - AR presentation module (`ARSceneController`) owning anchors/entities and translating domain updates.
  - Sync module (`SharePlaySyncEngine`) with versioned schema and message validation, separated from UI.
  - Input module combining gestures + face tracking + audio triggers with debounce and permissions handling.
- **State management:** Single source of truth in `CharacterStore` (observable), with reducers for actions/effects; coordinator adapts to AR scene and SharePlay events.
- **Assets:** Asset loader pipeline for USDZ + skeletal animations; audio catalog with preloading.
- **Testing hooks:** Deterministic simulators for SharePlay messages, AR-less mode for unit tests, and snapshot tests for reducers.

### 3.3 System Boundaries
- **SharePlay:** GroupActivities session, messenger, message schema (spawn/update/remove/action/effect), participant tracking.
- **AR:** Session configuration (face vs world tracking), anchor management, gesture-to-domain mapping, camera pose updates.
- **Character:** Domain model + factory + animation controller; mapping to RealityKit entities.
- **Haptics:** Centralized `HapticManager` triggered by inputs, state changes, and expression success.
- **Audio:** `AudioService` handling SFX playback and microphone-based triggers.

### 3.4 Data Flow Diagrams (Textual)
- **Gesture -> Character update -> SharePlay:**
  - UIKit gesture (tap/pan/pinch) → `MagicARView.Coordinator` → `CharacterViewModel.updateCharacterPosition/Scale` → domain model mutates → AR anchor rebinds → `SharePlayService.sendCharacterUpdated` (throttled) → remote `SharePlayService` → `CharacterViewModel.sharePlayDidUpdateCharacter` → remote character updated.
- **Face tracking -> Expression -> Action/Effect:**
  - ARKit face anchor → `FaceTrackingService.processFaceAnchor` (thresholds/debounce) → delegate → `CharacterViewModel.handleFaceExpression` → action/effect dispatch → AR animation + SharePlay broadcast.
- **Audio clap -> Jump:**
  - `AudioService.analyzeAudioBuffer` detects RMS threshold → publishes `loudNoiseDetected` → `CharacterViewModel.handleLoudNoise` → `performAction(.jump)` on all characters → SharePlay action broadcast.
- **Error propagation:**
  - Service error → `AppError` → `ErrorLoggingService` log → `ContentView` receives via `@Published` → SwiftUI `Alert` presented.

## 4. Feature Specifications
_For each feature: user story, requirements, dependencies, success criteria, complexity (1-5), priority._

### AR session bootstrap & gesture input
- **User Story:** As a child, I can place and manipulate characters in my room with simple taps, drags, and pinches.
- **Requirements:** Face/world tracking configuration with graceful fallback; tap-to-spawn; pan-to-move; pinch-to-scale; haptic feedback; pause/resume with scene phase.
- **Dependencies:** ARKit, RealityKit, `CharacterViewModel`, `HapticManager`.
- **Success Criteria:** Gestures update domain state and render; AR session resumes after interruption; errors surfaced non-fatally.
- **Complexity:** 3; **Priority:** P0.

### Character spawning & actions
- **User Story:** As a user, I can choose a princess and make her wave, dance, twirl, or jump.
- **Requirements:** Character factory, selection UI, action dispatcher, animation controller, sound hooks.
- **Dependencies:** RealityKit, `AudioService`, `HapticManager`, `SharePlayService`.
- **Success Criteria:** Actions animate locally and sync to peers; removal cleans up entities and pending animations.
- **Complexity:** 3; **Priority:** P0.

### Face-expression-driven magic
- **User Story:** When I smile or raise my eyebrows, the app reacts with sparkles or waves automatically.
- **Requirements:** Face tracking delegate, thresholds/debounce, mapping expressions to actions/effects, accessibility fallback when face tracking unavailable.
- **Dependencies:** ARKit FaceTracking, `HapticManager`, `CharacterViewModel`, `SharePlayService`.
- **Success Criteria:** Expressions trigger within 300ms and do not spam; disabled gracefully on unsupported devices.
- **Complexity:** 3; **Priority:** P1.

### Magic effects (sparkles/snow/bubbles)
- **User Story:** I can add magical sparkles, snow, or bubbles around characters.
- **Requirements:** Effect selection UI, particle emitters, lifetime management, audio cues, SharePlay sync.
- **Dependencies:** RealityKit, `AudioService`, `SharePlayService`.
- **Success Criteria:** Effects render at target position, auto-cleanup, sync across peers without duplication.
- **Complexity:** 3; **Priority:** P1.

### SharePlay synchronization
- **User Story:** My friend sees the same characters, positions, actions, and effects during FaceTime.
- **Requirements:** Versioned message schema, messenger resilience, throttled updates, conflict resolution, backward compatibility, error surfacing.
- **Dependencies:** GroupActivities, `CharacterViewModel`, message codecs.
- **Success Criteria:** Join/leave stability; no duplicate spawns; consistent state after reconnect; schema without conflicts.
- **Complexity:** 4; **Priority:** P0.

### Audio SFX & microphone reactions
- **User Story:** Sounds play for actions/effects, and claps trigger character jumps.
- **Requirements:** Asset catalog, preloading, volume controls, mic permission flow, RMS threshold tuning, error handling.
- **Dependencies:** AVFoundation, `CharacterViewModel`, `SharePlayService` (for synced jumps).
- **Success Criteria:** <100ms playback latency; mic monitoring toggleable; no crashes without mic permission.
- **Complexity:** 3; **Priority:** P2.

### Haptics & accessibility
- **User Story:** I feel subtle vibrations on interactions respecting accessibility settings.
- **Requirements:** Central haptic router, reduce-motion compliance, per-event patterns, settings toggles.
- **Dependencies:** UIKit haptics, `SettingsService` (future).
- **Success Criteria:** No haptics when disabled or reduce-motion on; distinct patterns per event.
- **Complexity:** 2; **Priority:** P2.

### Onboarding & settings
- **User Story:** First-time users learn controls; parents adjust sound/haptics/safety settings.
- **Requirements:** Onboarding carousel/modal, persisted settings, bindings to services.
- **Dependencies:** SwiftUI, `SettingsService`, `AudioService`, `HapticManager`.
- **Success Criteria:** Dismissable onboarding; settings persist between launches and affect services immediately.
- **Complexity:** 2; **Priority:** P2.

## 5. Current State Assessment
- **Codebase health:** Multiple compile blockers (merge conflicts, missing APIs, duplicate properties). No tests. Placeholder assets. Mixed legacy vs new SharePlay schema.
- **Compile blockers:**
  - `SyncMessage` conflict markers and mismatched fields in `SharePlayService`.
  - Duplicate `characterType` (stored + computed, referencing undefined `type`) in `Character`.
  - Call to undefined `CharacterViewModel.updateCameraPosition` from `MagicARView`.
- **Merge conflict areas:** `Services/SharePlayService.swift` around `SyncMessage` and delegate definitions.
- **Duplicate/conflicting implementations:** Two SharePlay delegate protocols and dual message schemas; haptic settings flags unused; particle systems duplicated (basic vs enhanced) without a single entry point.
- **Missing APIs/incomplete integrations:**
  - Settings UI and bindings.
  - Asset loading/audio playback implementations.
  - Gesture-to-view-model syncing for move/scale.
  - SharePlay effect/action schema normalization.

## 6. Rebuild vs. Repair Analysis
- **Repair cost (high):** Untangle SharePlay conflicts, reconcile character model issues, add missing APIs, retrofit asset pipeline, and add tests. Significant risk of hidden regressions due to inconsistent schemas and duplicated logic.
- **Rebuild cost (moderate):** Stand up clean modules with defined protocols and schemas, then port usable utilities (particle presets, audio/mic scaffolding). Enables testable architecture and avoids conflict cleanup.
- **Recommendation:** Rebuild core modules (domain, AR coordinator, SharePlay sync, settings) while salvaging reusable utilities. This avoids prolonged conflict resolution and provides a stable base for assets/tests.
- **Phased approach:**
  1. Define domain protocols + state store; implement AR coordinator that consumes store.
  2. Ship versioned SharePlay schema with conformance tests and simulators.
  3. Integrate assets (USDZ + audio) and hook particle manager into scene.
  4. Add onboarding/settings with persisted toggles; finalize haptic/audio routing.
  5. Regression suite (unit + integration) and manual AR test plan.

## 7. Migration Strategy
- **Salvage:**
  - Particle presets (`Effects/EnhancedParticleEffects.swift`), basic effect enums (`Models/MagicEffect.swift`).
  - Audio/mic monitoring scaffolding (`Services/AudioService.swift`).
  - Face-tracking thresholds/debounce logic (`Services/FaceTrackingService.swift`).
  - UI composition patterns in `ContentView` and gesture setup in `MagicARView` (sans direct entity mutation).
- **Rewrite:**
  - SharePlay messaging/service with clean schema and tests.
  - Character domain model + factory (remove duplicate properties, protocol clarity).
  - AR coordinator to route gestures through view-model/state store and observe camera pose.
  - Settings/onboarding views and settings service; haptic manager integration.
- **Integration tests:**
  - Simulated SharePlay sessions for spawn/update/remove/action/effect roundtrips.
  - AR-less gesture/unit tests for reducers; face-tracking mock anchor tests.
- **Rollout phases:** Dev preview (local only) → SharePlay beta (with telemetry-free diagnostics) → asset drop (real models/animations) → polished release.

## 8. Open Questions
- Which message schema/version should be canonical for SharePlay? How to handle legacy clients?
- What are the target asset formats (USDZ vs Reality Composer Pro) and animation requirements?
- Desired audio palette and licensing? Are sound assets available?
- Should clap detection be optional/tunable for accessibility?
- Are there privacy constraints beyond on-device processing (e.g., no mic buffering)?
- What testing matrix/devices are available for face-tracking vs world-tracking-only hardware?