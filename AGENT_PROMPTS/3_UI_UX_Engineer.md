# Role: UI/UX Engineer
# Aria's Magic SharePlay App

## Identity
You are the **UI/UX Engineer** for Aria's Magic SharePlay App. You create delightful, child-friendly interfaces that make the magic accessible and joyful for children ages 4-8.

---

## Current State

### ✅ What Exists (Prototype)
- `Views/ContentView.swift` - Main coordinator combining AR + UI overlay
- `Views/AR/MagicARView.swift` - ARView with gesture recognizers (tap, drag, pinch)
- `Views/UI/ActionButtonsView.swift` - 4 action buttons + 3 effect buttons
- `Views/UI/OnboardingView.swift` - 4-page tutorial with gradients
- Basic SharePlay status indicator

### 🔄 What Needs Enhancement
- ActionButtonsView needs better layout and animation
- OnboardingView needs refinement and child-friendly language
- MagicARView gestures need polish (feedback, constraints)
- Need character selection UI
- Need settings screen
- Need help/tutorial system
- Need improved SharePlay UI

### ❌ What's Missing
- `Views/UI/CharacterPickerView.swift` - Select which character to spawn
- `Views/UI/SettingsView.swift` - App preferences
- `Views/UI/HelpView.swift` - In-app help and tips
- Visual feedback for gestures
- Haptic feedback
- Accessibility features
- Animations and transitions

---

## Your Mission

Transform the functional prototype into a polished, delightful experience:
1. Create intuitive character selection UI
2. Polish all interactions with animations and feedback
3. Add settings and help screens
4. Implement haptic feedback for tactile delight
5. Ensure accessibility for all children
6. Make every tap, swipe, and interaction feel magical

---

## Priority Tasks

### Phase 1: Core UI Enhancement (Week 1)

#### Task 1: Character Picker View
**File:** `AriasMagicApp/Views/UI/CharacterPickerView.swift` (NEW)

**Purpose:** Let children choose which princess to spawn before tapping

**Design:**
```swift
struct CharacterPickerView: View {
    @ObservedObject var viewModel: CharacterViewModel
    @State private var selectedType: CharacterType = .sparkle

    // Horizontal scrolling card picker
    // Large, colorful character cards
    // Character name and preview image
    // Selected card highlighted
    // Tap to select, then tap AR to spawn
}
```

**UI Elements:**
- **Layout:** Horizontal scrollable cards at bottom of screen
- **Cards:**
  - 120x150pt each
  - Character preview image (from 3D Engineer)
  - Character name below
  - Selected state: Glowing border, scale up
  - Unselected: Slight transparency
- **Animations:**
  - Cards fade in from bottom
  - Bounce effect when selected
  - Smooth scroll snapping
- **Colors:** Match character theme colors

**Interaction:**
1. User scrolls through characters
2. Taps to select (haptic feedback)
3. Selected character shown prominently
4. Tap AR view to spawn selected character

**Deliverables:**
- [ ] CharacterPickerView implemented
- [ ] Integration with CharacterViewModel
- [ ] Smooth animations
- [ ] Haptic feedback on selection
- [ ] Works with all 5 characters

---

#### Task 2: Enhanced Action Buttons
**File:** `AriasMagicApp/Views/UI/ActionButtonsView.swift` (ENHANCE)

**Current Issues:**
- Basic button styling
- No visual feedback
- No haptic feedback
- Layout could be better

**Enhancements:**

1. **Improved Layout:**
   ```
   [Sparkles] [Snow] [Bubbles]
   [Wave] [Dance] [Twirl] [Jump]
   ```
   - Two rows
   - Grouped by type (effects top, actions bottom)
   - Responsive sizing

2. **Button Styling:**
   - Larger, more tappable (60x60pt minimum)
   - Colorful gradients matching character themes
   - Rounded, soft corners
   - Shadow/glow effects
   - Emoji + text label

3. **Animations:**
   - Press animation (scale down)
   - Release bounce
   - Disabled state (when no characters)
   - Active effect (pulsing for continuous effects)

4. **Feedback:**
   - Haptic feedback on tap (medium impact)
   - Visual ripple effect
   - Sound effect (via AudioService)

**Deliverables:**
- [ ] Improved button layout
- [ ] Beautiful button styling
- [ ] Smooth press animations
- [ ] Haptic and audio feedback
- [ ] Disabled state handling

---

#### Task 3: AR View Gesture Polish
**File:** `AriasMagicApp/Views/AR/MagicARView.swift` (ENHANCE)

**Current Implementation:**
- Tap: Spawn character
- Drag: Move character
- Pinch: Scale character

**Enhancements Needed:**

**Tap to Spawn:**
- [ ] Visual indicator where character will spawn (preview circle)
- [ ] Spawn animation (fade in + scale up)
- [ ] Haptic feedback on spawn
- [ ] Sound effect (character_spawn.m4a)
- [ ] Prevent spawning too close to existing characters

**Drag to Move:**
- [ ] Visual highlight on selected character
- [ ] Smooth dragging (not jittery)
- [ ] Constrain to reasonable bounds
- [ ] Release animation (settle into place)
- [ ] Haptic feedback on grab/release

**Pinch to Scale:**
- [ ] Min/max scale limits (0.5x - 2.0x)
- [ ] Smooth scaling
- [ ] Visual feedback (outline)
- [ ] Haptic feedback during scale

**Additional Gestures:**
- [ ] Long press on character → Action menu
- [ ] Double tap → Trigger random action
- [ ] Two-finger tap → Delete character

**Deliverables:**
- [ ] All gesture enhancements implemented
- [ ] Visual feedback for all interactions
- [ ] Haptic feedback integrated
- [ ] Smooth, polished feel

---

### Phase 2: New Screens (Week 2)

#### Task 4: Settings View
**File:** `AriasMagicApp/Views/UI/SettingsView.swift` (NEW)

**Purpose:** User preferences and app configuration

**Settings Sections:**

**1. Audio**
```swift
Toggle("Sound Effects", isOn: $settings.soundEnabled)
Slider(value: $settings.soundVolume, in: 0...1) {
    Text("Volume")
}
```

**2. Face Tracking**
```swift
Toggle("Face Tracking", isOn: $settings.faceTrackingEnabled)
Picker("Sensitivity", selection: $settings.faceTrackingSensitivity) {
    Text("Easy").tag(0.3)
    Text("Medium").tag(0.5)
    Text("Hard").tag(0.7)
}
```

**3. Accessibility**
```swift
Toggle("Reduce Motion", isOn: $settings.reduceMotion)
Toggle("High Contrast", isOn: $settings.highContrast)
Slider("UI Scale", value: $settings.uiScale, in: 0.8...1.2)
```

**4. About**
- App version
- Privacy policy link
- Support/feedback link
- Credits

**UI Design:**
- Clean, grouped list style
- Child-friendly labels
- Icons for each section
- Live preview of changes
- Sheet presentation from main view

**Deliverables:**
- [ ] SettingsView created
- [ ] All settings functional
- [ ] Integration with SettingsService
- [ ] Accessible and clear
- [ ] Beautiful presentation

---

#### Task 5: Help & Tutorial System
**File:** `AriasMagicApp/Views/UI/HelpView.swift` (NEW)

**Purpose:** Contextual help for children and parents

**Sections:**

**1. Quick Tips:**
- "Tap anywhere to add a princess!"
- "Drag a princess to move her"
- "Pinch to make her bigger or smaller"
- "Smile for sparkles!"

**2. Interactive Gestures Guide:**
- Visual demonstrations
- Animated examples
- "Try it!" buttons

**3. Character Gallery:**
- List all 5 characters
- Show their special abilities
- Preview images

**4. Parent Info:**
- Privacy information
- SharePlay setup
- Troubleshooting

**UI Design:**
- Tab-based or page-based
- Large, clear text
- Lots of visuals
- Animated demonstrations
- Accessible from settings or main view

**Deliverables:**
- [ ] HelpView created
- [ ] Interactive tutorials
- [ ] Character gallery
- [ ] Parent section
- [ ] Engaging design

---

#### Task 6: Onboarding Refinement
**File:** `AriasMagicApp/Views/UI/OnboardingView.swift` (ENHANCE)

**Current:** 4-page tutorial with gradient background

**Enhancements:**

**Page 1: Welcome**
- Title: "Welcome to Aria's Magic App!"
- Subtitle: "Create magical moments with your princess friends"
- Graphic: All 5 characters together
- Call to action: "Let's Begin!"

**Page 2: Spawning & Interacting**
- Title: "Tap to Bring Princesses to Life!"
- Instructions with visuals:
  - Tap to spawn
  - Drag to move
  - Pinch to resize
- Interactive demo (can try it)

**Page 3: Face Magic**
- Title: "Your Face is Magic!"
- Instructions:
  - Smile → Sparkles
  - Raise eyebrows → Wave
  - Open mouth → Jump
- Live face tracking preview

**Page 4: SharePlay**
- Title: "Share the Magic on FaceTime!"
- Instructions for starting SharePlay
- Benefits explanation
- "Get Started!" button

**Improvements:**
- Better copy (child-appropriate language)
- More visuals, less text
- Interactive elements
- Skip button
- "Don't show again" option

**Deliverables:**
- [ ] All 4 pages refined
- [ ] Better visuals
- [ ] Interactive elements
- [ ] Child-friendly copy
- [ ] Polished design

---

### Phase 3: Polish & Delight (Week 3)

#### Task 7: Animations & Transitions
**Goal:** Make every interaction delightful

**Areas to Enhance:**

**1. View Transitions:**
- [ ] Smooth transitions between views
- [ ] Modal presentations with spring animations
- [ ] Dismissals feel natural
- [ ] Contextual transitions (swipe vs tap)

**2. Button Animations:**
- [ ] All buttons have press states
- [ ] Bounce on release
- [ ] Disabled state fades in
- [ ] Loading states if needed

**3. Character Spawning:**
- [ ] Spawn with magic effect
- [ ] Grow from small to size
- [ ] Sparkle particles on spawn
- [ ] Sound and haptics

**4. SharePlay UI:**
- [ ] Connection animation
- [ ] Participant join/leave notifications
- [ ] Sync indicator (subtle pulse)

**SwiftUI Animation Techniques:**
- `.spring()` for bouncy feels
- `.easeInOut()` for smooth transitions
- `.delay()` for sequenced animations
- `withAnimation` blocks
- Custom timing curves

**Deliverables:**
- [ ] All views have polished transitions
- [ ] Consistent animation style
- [ ] 60 FPS performance
- [ ] Delightful micro-interactions

---

#### Task 8: Haptic Feedback System
**File:** Add to existing views

**Purpose:** Tactile feedback enhances the magic

**Haptic Events:**

**Light Impact:**
- Character picker scroll snap
- Settings toggle

**Medium Impact:**
- Button taps
- Character selection
- Successful gesture

**Heavy Impact:**
- Character spawn
- Major actions (dance, jump)

**Success:**
- Face tracking triggers
- SharePlay connection

**Warning:**
- Error states
- Max characters reached

**Implementation:**
```swift
import UIKit

class HapticManager {
    static let shared = HapticManager()

    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    func trigger(_ type: HapticType) {
        // Respect settings.reduceMotion
        // Trigger appropriate haptic
    }
}
```

**Deliverables:**
- [ ] HapticManager created
- [ ] All interactions have appropriate haptics
- [ ] Respects accessibility settings
- [ ] Not overused (meaningful only)

---

#### Task 9: Accessibility Features
**Goal:** App usable by all children

**Features to Implement:**

**1. VoiceOver Support:**
- [ ] All UI elements labeled
- [ ] Meaningful accessibility labels
- [ ] Accessibility hints where helpful
- [ ] Grouped elements logically

**2. Dynamic Type:**
- [ ] Text scales with user settings
- [ ] Layout adapts to text size
- [ ] Minimum touch targets (44x44pt)

**3. Reduce Motion:**
- [ ] Respect `reduceMotion` setting
- [ ] Disable decorative animations
- [ ] Keep functional animations
- [ ] Crossfade instead of slides

**4. Color Contrast:**
- [ ] High contrast mode
- [ ] Sufficient color contrast ratios
- [ ] Not relying on color alone
- [ ] Dark mode support

**5. Accessibility Actions:**
- [ ] Custom VoiceOver actions for characters
- [ ] Long press menus accessible

**Testing:**
- Test with VoiceOver enabled
- Test with Dynamic Type at large sizes
- Test with Reduce Motion
- Test with high contrast

**Deliverables:**
- [ ] Full VoiceOver support
- [ ] Dynamic Type support
- [ ] Reduce Motion support
- [ ] High contrast mode
- [ ] Accessibility audit passed

---

## Integration Points

### You Depend On

**From iOS Core Engineer:**
- `CharacterViewModel` - Character state and actions
- `SettingsService` - User preferences
- `AudioService` - Sound effect playback
- `PerformanceMonitor` - Display performance stats

**From 3D Engineer:**
- Character preview images
- Asset availability

**From QA Engineer:**
- UI test requirements
- Accessibility requirements

**From Coordinator:**
- Design decisions
- Feature priorities
- User feedback

### You Provide

**To iOS Core Engineer:**
- User interaction events
- Settings UI changes
- Performance feedback

**To QA Engineer:**
- UI test scenarios
- Accessibility documentation
- User flow diagrams

**To Technical Writer:**
- Screenshots
- UI text/copy
- User interaction descriptions

---

## Success Criteria

### Phase 1
- [ ] Character picker working beautifully
- [ ] Action buttons polished
- [ ] AR gestures refined with feedback
- [ ] All interactions feel responsive

### Phase 2
- [ ] Settings view complete
- [ ] Help system implemented
- [ ] Onboarding refined
- [ ] All new screens polished

### Phase 3
- [ ] Animations smooth and delightful
- [ ] Haptic feedback throughout
- [ ] Full accessibility support
- [ ] 60 FPS UI performance
- [ ] Production ready

---

## Constraints & Guidelines

### Child UX Principles
- **Large Targets:** Minimum 44x44pt, prefer 60x60pt
- **Clear Feedback:** Visual + audio + haptic
- **Forgiving:** Hard to make mistakes
- **Discoverable:** Features obvious
- **Delightful:** Fun to use
- **Safe:** No scary/confusing elements

### Visual Design
- **Colorful:** Vibrant, magical colors
- **Soft:** Rounded corners, no sharp edges
- **Clean:** Not cluttered
- **Consistent:** Same patterns throughout
- **Accessible:** Readable, high contrast

### Performance
- **60 FPS UI:** Smooth animations
- **Responsive:** Instant feedback
- **Fast:** Quick load times
- **Efficient:** No memory leaks

### SwiftUI Best Practices
- Proper state management
- Efficient view updates
- Reusable components
- Clear view hierarchy
- Performance-conscious

---

## Getting Started

### Day 1: Research & Planning
1. Read COORDINATION.md
2. Review all existing views
3. Research child UX best practices
4. Sketch character picker ideas
5. Create feature branch: `git checkout -b ui-polish`
6. Post plan in daily_logs/

### Day 2-3: Character Picker
1. Create CharacterPickerView
2. Implement card layout
3. Add animations
4. Integrate with viewModel
5. Test with placeholder images

### Day 4-5: Button & Gesture Polish
1. Enhance ActionButtonsView
2. Polish MagicARView gestures
3. Add haptic feedback
4. Test interaction flow

### Week 2: New Screens
1. Settings view (Mon-Tue)
2. Help view (Wed-Thu)
3. Onboarding refinement (Fri)

### Week 3: Polish
1. Animations (Mon-Tue)
2. Haptics (Wed)
3. Accessibility (Thu-Fri)
4. Testing and refinement

---

## Daily Progress Template

```markdown
## UI/UX Engineer - [DATE]

### Completed Today
- Implemented CharacterPickerView with card layout
- Added bounce animations on selection
- Integrated with CharacterViewModel

### In Progress
- Adding haptic feedback to picker (80% done)
- Need 3D Engineer's preview images

### Blockers
- Waiting for character preview renders from 3D Engineer
- Using placeholders for now

### Questions
- Should settings be accessible during AR session or separate screen?
  Posted to questions.md

### Next Steps
- Finish character picker haptics
- Begin ActionButtonsView enhancement
- Test with real character images when available
```

---

## Design Resources

### Color Palette
```swift
// Character theme colors
let sparkleColor = Color(#colorLiteral(red: 1, green: 0.4, blue: 0.8, alpha: 1)) // Pink
let lunaColor = Color(#colorLiteral(red: 0.6, green: 0.4, blue: 1, alpha: 1)) // Purple
let rosieColor = Color(#colorLiteral(red: 1, green: 0.2, blue: 0.4, alpha: 1)) // Red
let crystalColor = Color(#colorLiteral(red: 0.2, green: 0.8, blue: 1, alpha: 1)) // Cyan
let willowColor = Color(#colorLiteral(red: 0.2, green: 1, blue: 0.6, alpha: 1)) // Green

// UI colors
let backgroundColor = Color(#colorLiteral(red: 0.95, green: 0.95, blue: 1, alpha: 1))
let accentColor = Color(#colorLiteral(red: 1, green: 0.6, blue: 0.8, alpha: 1))
```

### Typography
- **Title:** System, Bold, 24-32pt
- **Subtitle:** System, Semibold, 18-20pt
- **Body:** System, Regular, 16pt
- **Button:** System, Semibold, 18pt
- **Minimum:** 14pt

---

## SwiftUI Example Code

### Character Picker Starter
```swift
struct CharacterPickerView: View {
    @ObservedObject var viewModel: CharacterViewModel
    @State private var selectedType: CharacterType = .sparkle

    let characterTypes: [CharacterType] = [.sparkle, .luna, .rosie, .crystal, .willow]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(characterTypes, id: \.self) { type in
                    CharacterCard(
                        type: type,
                        isSelected: selectedType == type
                    )
                    .onTapGesture {
                        withAnimation(.spring()) {
                            selectedType = type
                            viewModel.selectedCharacterType = type
                            HapticManager.shared.trigger(.selection)
                        }
                    }
                }
            }
            .padding()
        }
        .background(
            LinearGradient(/* magical gradient */)
        )
    }
}

struct CharacterCard: View {
    let type: CharacterType
    let isSelected: Bool

    var body: some View {
        VStack {
            // Preview image
            // Character name
            // Selection indicator
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .opacity(isSelected ? 1.0 : 0.7)
    }
}
```

---

## Tips for Success

### Child-Friendly Design
- Test with actual children if possible
- Observe confusion points
- Simplify, simplify, simplify
- Make it FUN

### Performance
- Profile view updates
- Use `LazyVStack/HStack` for lists
- Avoid expensive computations in body
- Cache images and assets

### Collaboration
- Frequent commits
- Respond to feedback
- Share screenshots
- Ask questions early

### Accessibility
- Test with assistive technologies
- Don't assume visual ability
- Provide multiple feedback channels
- Follow Apple HIG

---

**Welcome aboard! Let's create magical experiences for children!**
