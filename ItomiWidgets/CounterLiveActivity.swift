// The Lock Screen card and Dynamic Island: part, round, Undo and a big + button

import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

// Itomi's colors (the widget has its own asset catalog, so they're spelled out here)
extension Color {
    static let itomiPlum = Color(red: 0.431, green: 0.231, blue: 0.361)
    static let itomiCream = Color(red: 0.965, green: 0.925, blue: 0.894)
    static let itomiPink = Color(red: 0.886, green: 0.722, blue: 0.824)
}

struct CounterLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CounterActivityAttributes.self) { context in
            LockScreenCard(state: context.state)
                .activityBackgroundTint(Color.itomiPlum)
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    RoundLabel(state: context.state)
                        .padding(.leading, 6)
                        .dynamicIsland(verticalPlacement: .belowIfTooWide)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    CounterButtons()
                        .padding(.trailing, 4)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.plannedRounds != nil {
                        ProgressView(value: context.state.progress)
                            .tint(Color.itomiPink)
                            .padding(.horizontal, 6)
                    }
                }
            } compactLeading: {
                LoopMark(size: 20, color: Color.itomiPink)
            } compactTrailing: {
                // e.g. "R6" for round 6
                Text("\(context.state.countWord.prefix(1))\(context.state.round)")
                    .fontWeight(.bold)
                    .foregroundStyle(Color.itomiPink)
                    .accessibilityLabel("\(context.state.countWord) \(context.state.round)")
            } minimal: {
                Text("\(context.state.round)")
                    .fontWeight(.bold)
                    .foregroundStyle(Color.itomiPink)
                    .accessibilityLabel("\(context.state.countWord) \(context.state.round)")
            }
            .keylineTint(Color.itomiPink)
        }
    }
}

// The card on the Lock Screen
struct LockScreenCard: View {
    let state: CounterActivityAttributes.ContentState

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                LoopMark(size: 26, color: Color.itomiCream)
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 11))
                RoundLabel(state: state)
                Spacer(minLength: 0)
                CounterButtons()
            }
            if state.plannedRounds != nil {
                ProgressView(value: state.progress)
                    .tint(Color.itomiPink)
            }
        }
        .padding(16)
        .foregroundStyle(.white)
        .fontDesign(.rounded)
    }
}

// "Bunny · Head" over "Round 6 of 22"
struct RoundLabel: View {
    let state: CounterActivityAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(state.title)
                .font(.subheadline)
                .opacity(0.85)
                .lineLimit(1)
            Text(state.roundText)
                .font(.title2)
                .fontWeight(.heavy)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .contentTransition(.numericText())
        }
        .foregroundStyle(.white)
        .fontDesign(.rounded)
        .accessibilityElement(children: .combine)
    }
}

// Undo and the big cream + button
struct CounterButtons: View {
    var body: some View {
        HStack(spacing: 10) {
            Button(intent: UndoRoundIntent()) {
                Image(systemName: "arrow.uturn.backward")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(.white.opacity(0.18), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Undo")

            Button(intent: AddRoundIntent()) {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.itomiPlum)
                    .frame(width: 56, height: 56)
                    .background(Color.itomiCream, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add a round")
        }
    }
}
