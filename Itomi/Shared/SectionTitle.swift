// Bold black section titles, a smaller match for the big page titles

import SwiftUI

struct SectionTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.title3)
            .fontWeight(.bold)
            .foregroundStyle(Color.primary)
            .textCase(nil)
    }
}

// The same title as a list section header, lined up with the card's edge
struct ListSectionTitle: View {
    let text: String

    var body: some View {
        SectionTitle(text: text)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
    }
}
