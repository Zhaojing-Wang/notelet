//
//  noteletApp.swift
//  notelet
//
//  Created by Zhaojing Wang on 4/25/26.
//

import SwiftUI

@main
struct noteletApp: App {
    @StateObject private var historyStore = HistoryStore()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(historyStore)
        }
    }
}
