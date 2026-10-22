// Settings → Appearance (Pro): pick a theme color and the matching home screen icon

import SwiftUI
import UIKit

struct AppearanceView: View {
    @AppStorage("theme") private var themeName = Theme.plum.rawValue
    @AppStorage("matchIcon") private var matchIcon = true
    @AppStorage("creamIcon") private var creamIcon = false

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        Form {
            Section {
                preview
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            Section {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Theme.allCases) { theme in
                        ThemeSwatch(theme: theme, isPicked: theme == pickedTheme) {
                            pick(theme)
                        }
                    }
                }
                .padding(.vertical, 8)
            } header: {
                ListSectionTitle(text: "Theme")
            }

            Section {
                Toggle(isOn: $matchIcon) {
                    Text("Match app icon")
                    Text("The home screen icon follows your theme")
                }
                Button {
                    creamIcon.toggle()
                    Haptics.light()
                    updateAppIcon()
                } label: {
                    HStack(spacing: 12) {
                        LoopMark(size: 24, color: .accent)
                            .frame(width: 36, height: 36)
                            .background(Color.cream, in: RoundedRectangle(cornerRadius: 9))
                        Text("Cream icon instead")
                            .foregroundStyle(.primary)
                        Spacer()
                        if creamIcon {
                            Image(systemName: "checkmark")
                                .fontWeight(.bold)
                                .foregroundStyle(pickedTheme.color)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } footer: {
                Text("Every theme keeps the counter number bold white and easy to read.")
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.warmBackground)
        .navigationTitle("Appearance")
        .onChange(of: matchIcon) {
            Haptics.light()
            updateAppIcon()
        }
    }

    // The mini counter and the home screen icon, as they'll look
    var preview: some View {
        HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text("ROUND")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .opacity(0.8)
                Text("6")
                    .font(.system(size: 56, design: .rounded))
                    .fontWeight(.bold)
                Text("of 22")
                    .font(.caption)
                    .opacity(0.8)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 132)
            .background(pickedTheme.color, in: RoundedRectangle(cornerRadius: 24))

            LoopMark(size: 58, color: iconLoopColor)
                .frame(width: 96, height: 96)
                .background(iconBackground, in: RoundedRectangle(cornerRadius: 22))
        }
        .accessibilityHidden(true)
    }

    var pickedTheme: Theme {
        return Theme(rawValue: themeName) ?? .plum
    }

    // Cream icon: plum loop on cream; otherwise a cream loop on plum or the theme color
    var iconBackground: Color {
        if creamIcon {
            return Color.cream
        }
        if matchIcon {
            return pickedTheme.color
        }
        return Color.accent
    }

    var iconLoopColor: Color {
        if creamIcon {
            return Color.accent
        }
        return Color.cream
    }

    func pick(_ theme: Theme) {
        themeName = theme.rawValue
        Haptics.light()
        updateAppIcon()
    }

    // Switch the home screen icon to match the picks (iOS shows its own short note when it changes)
    func updateAppIcon() {
        var wantedIcon: String? = nil
        if creamIcon {
            wantedIcon = "AppIcon-Cream"
        } else if matchIcon {
            wantedIcon = pickedTheme.iconName
        }

        if UIApplication.shared.alternateIconName == wantedIcon {
            return
        }
        UIApplication.shared.setAlternateIconName(wantedIcon) { error in
            if let error {
                print("Couldn't change the app icon: \(error)")
            }
        }
    }
}

// One color circle with its name, ringed when it's the picked theme
struct ThemeSwatch: View {
    let theme: Theme
    let isPicked: Bool
    let onPick: () -> Void

    var body: some View {
        Button {
            onPick()
        } label: {
            VStack(spacing: 6) {
                Circle()
                    .fill(theme.color)
                    .frame(width: 52, height: 52)
                    .padding(4)
                    .overlay {
                        if isPicked {
                            Circle()
                                .stroke(theme.color, lineWidth: 3)
                        }
                    }
                Text(theme.name)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(theme.name) theme")
        .accessibilityAddTraits(isPicked ? .isSelected : [])
    }
}
