// Everything the widget extension shows: for now, just the Lock Screen counter

import SwiftUI
import WidgetKit

@main
struct ItomiWidgetsBundle: WidgetBundle {
    var body: some Widget {
        CounterLiveActivity()
    }
}
