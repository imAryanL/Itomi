// Everything the widget extension shows: the Lock Screen counter and the Control Center button

import SwiftUI
import WidgetKit

@main
struct ItomiWidgetsBundle: WidgetBundle {
    var body: some Widget {
        CounterLiveActivity()
        CounterControl()
    }
}
