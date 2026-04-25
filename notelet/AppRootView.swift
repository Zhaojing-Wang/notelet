import SwiftUI

struct AppRootView: View {
    @State private var path: [EditorRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeView { route in
                path.append(route)
            }
            .navigationDestination(for: EditorRoute.self) { route in
                EditorView(route: route)
            }
        }
        .tint(Color.noteletInk)
    }
}
