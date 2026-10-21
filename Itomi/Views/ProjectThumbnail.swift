// A project's square picture: its photo, or a cream tile with the loop

import SwiftUI

struct ProjectThumbnail: View {
    let project: Project
    let size: CGFloat

    var body: some View {
        ZStack {
            if let data = project.photo, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.cream
                LoopMark(size: size * 0.6, color: .accent)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.25))
        .accessibilityHidden(true)
    }
}
