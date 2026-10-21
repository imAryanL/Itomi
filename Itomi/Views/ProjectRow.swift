// One project in the Projects list: thumbnail, name and where you're up to

import SwiftUI

struct ProjectRow: View {
    let project: Project

    var body: some View {
        HStack(spacing: 14) {
            ProjectThumbnail(project: project, size: 56)

            VStack(alignment: .leading, spacing: 2) {
                Text(project.name)
                    .font(.headline)
                Text(project.progressSummary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
