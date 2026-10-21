// One part in a project's parts list: name, status and a progress bar

import SwiftUI

struct PartRow: View {
    let part: Part

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(part.displayName)
                Spacer()
                if part.isDone {
                    Label("Done", systemImage: "checkmark")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                } else {
                    Text(part.statusText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            ProgressView(value: part.progress)
        }
        .padding(.vertical, 4)
    }
}
