//
//  HelpView.swift
//  Aria's Magic SharePlay App
//
//  Interactive help and tutorial system
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = 0

    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // Quick Tips
                QuickTipsView()
                    .tabItem {
                        Label("Tips", systemImage: "lightbulb.fill")
                    }
                    .tag(0)

                // Gestures Guide
                GesturesGuideView()
                    .tabItem {
                        Label("Gestures", systemImage: "hand.tap.fill")
                    }
                    .tag(1)

                // Character Gallery
                CharacterGalleryView()
                    .tabItem {
                        Label("Characters", systemImage: "sparkles")
                    }
                    .tag(2)

                // Parent Info
                ParentInfoView()
                    .tabItem {
                        Label("Parents", systemImage: "person.2.fill")
                    }
                    .tag(3)
            }
            .navigationTitle("Help & Tips")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        HapticManager.shared.trigger(.light)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Quick Tips
struct QuickTipsView: View {
    let tips: [(String, String, String)] = [
        ("hand.tap.fill", "Tap Anywhere", "Tap the screen to add a magical princess to your world!"),
        ("hand.draw.fill", "Drag to Move", "Touch and drag a princess to move her around your space"),
        ("arrow.up.left.and.arrow.down.right", "Pinch to Resize", "Use two fingers to pinch and make your princess bigger or smaller"),
        ("face.smiling.fill", "Smile for Magic", "Smile to create sparkles around your princesses!"),
        ("face.dashed.fill", "Raise Eyebrows", "Raise your eyebrows to make all princesses wave at you"),
        ("mouth.fill", "Open Mouth", "Open your mouth wide to make your princesses jump!"),
        ("button.horizontal.fill", "Use Action Buttons", "Tap the colorful buttons to make your princesses dance, twirl, and jump"),
        ("sparkles", "Add Magic Effects", "Try sparkles, snow, and bubbles to make your world magical"),
        ("person.2.fill", "Share on FaceTime", "Start a FaceTime call and use SharePlay to share the magic with friends!")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(tips, id: \.1) { icon, title, description in
                    TipCard(icon: icon, title: title, description: description)
                }
            }
            .padding()
        }
    }
}

struct TipCard: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(.pink)
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.pink.opacity(0.1))
        )
    }
}

// MARK: - Gestures Guide
struct GesturesGuideView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Learn the Magic Gestures")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                GestureDemo(
                    emoji: "👆",
                    title: "Tap to Spawn",
                    description: "Tap anywhere in your space to bring a princess to life!",
                    steps: [
                        "Choose your favorite princess from the picker",
                        "Look around your space",
                        "Tap where you want her to appear",
                        "Watch the magic happen!"
                    ]
                )

                GestureDemo(
                    emoji: "👋",
                    title: "Drag to Move",
                    description: "Touch and drag to move your princess around",
                    steps: [
                        "Touch a princess",
                        "Keep your finger down",
                        "Drag to move her",
                        "Lift your finger to release"
                    ]
                )

                GestureDemo(
                    emoji: "🤏",
                    title: "Pinch to Resize",
                    description: "Use two fingers to make her bigger or smaller",
                    steps: [
                        "Place two fingers on a princess",
                        "Pinch together to make her smaller",
                        "Spread apart to make her bigger",
                        "Find the perfect size!"
                    ]
                )

                GestureDemo(
                    emoji: "😊",
                    title: "Face Expressions",
                    description: "Your face controls the magic!",
                    steps: [
                        "Smile: Creates sparkles ✨",
                        "Raise eyebrows: Makes them wave 👋",
                        "Open mouth: Makes them jump ⬆️",
                        "Try different expressions!"
                    ]
                )
            }
            .padding()
        }
    }
}

struct GestureDemo: View {
    let emoji: String
    let title: String
    let description: String
    let steps: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(emoji)
                    .font(.system(size: 40))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)

                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.pink)

                        Text(step)
                            .font(.body)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(.leading, 8)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.purple.opacity(0.1))
        )
    }
}

// MARK: - Character Gallery
struct CharacterGalleryView: View {
    let characters: [(CharacterType, String, String, Color)] = [
        (.sparkleThePrincess, "✨", "Loves to spread sparkles and joy wherever she goes!", Color(red: 1.0, green: 0.4, blue: 0.8)),
        (.lunaTheStarDancer, "🌙", "Dances under the stars and makes wishes come true!", Color(red: 0.6, green: 0.4, blue: 1.0)),
        (.rosieTheDreamWeaver, "🌹", "Weaves beautiful dreams and creates magical moments!", Color(red: 1.0, green: 0.2, blue: 0.4)),
        (.crystalTheGemKeeper, "💎", "Protects precious gems and shares their sparkle!", Color(red: 0.2, green: 0.8, blue: 1.0)),
        (.willowTheWishMaker, "🌿", "Grants wishes and brings nature's magic to life!", Color(red: 0.2, green: 1.0, blue: 0.6))
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Meet the Magical Princesses")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                ForEach(characters, id: \.0) { type, emoji, description, color in
                    CharacterCard(
                        name: type.rawValue,
                        emoji: emoji,
                        description: description,
                        color: color
                    )
                }
            }
            .padding()
        }
    }
}

struct CharacterCard: View {
    let name: String
    let emoji: String
    let description: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 70, height: 70)

                    Text(emoji)
                        .font(.system(size: 40))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Parent Info
struct ParentInfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Information for Parents")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)

                ParentSection(
                    icon: "hand.raised.fill",
                    title: "Privacy & Safety",
                    content: """
                    This app is designed with child safety as our top priority:

                    • All face tracking happens on-device
                    • No data is collected or stored
                    • No internet connection required (except for SharePlay)
                    • Camera data is never saved or transmitted
                    • SharePlay only shares AR content, not personal data
                    """
                )

                ParentSection(
                    icon: "person.2.fill",
                    title: "SharePlay Setup",
                    content: """
                    To share the magic on FaceTime:

                    1. Start a FaceTime call with family or friends
                    2. Open Aria's Magic SharePlay App
                    3. Tap the SharePlay button when prompted
                    4. Everyone on the call can now see and interact with the same magical characters!

                    Note: Each person needs the app installed to participate.
                    """
                )

                ParentSection(
                    icon: "exclamationmark.triangle.fill",
                    title: "Troubleshooting",
                    content: """
                    Common issues and solutions:

                    Face tracking not working:
                    • Make sure you're in good lighting
                    • Face the camera directly
                    • Check Face Tracking is enabled in Settings

                    Characters not appearing:
                    • Move your device around to scan the surface
                    • Tap on a flat, well-lit surface
                    • Make sure there's enough space

                    SharePlay not connecting:
                    • Ensure both devices have good internet
                    • Update to the latest iOS version
                    • Restart the FaceTime call
                    """
                )

                ParentSection(
                    icon: "accessibility.fill",
                    title: "Accessibility",
                    content: """
                    The app includes features for all children:

                    • VoiceOver support for visual accessibility
                    • Reduce Motion option for sensitive users
                    • High Contrast mode for better visibility
                    • Adjustable UI scale
                    • Large touch targets for easier interaction
                    """
                )

                ParentSection(
                    icon: "clock.fill",
                    title: "Recommended Usage",
                    content: """
                    For the best experience:

                    • Sessions of 15-30 minutes at a time
                    • Take breaks to rest eyes and move around
                    • Play in well-lit spaces
                    • Supervise younger children (ages 4-5)
                    • Encourage creative play and imagination
                    """
                )
            }
            .padding()
        }
    }
}

struct ParentSection: View {
    let icon: String
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.pink)

                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
            }

            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.purple.opacity(0.1))
        )
    }
}

#Preview {
    HelpView()
}
