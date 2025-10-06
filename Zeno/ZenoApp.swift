//
//  ZenoApp.swift
//  Zeno
//
//  Created by Sukidhar Darisi on 05/10/25.
//

import SwiftUI

@main
struct ZenoApp: App {
    @AppStorage("showStatusBar") var showStatusBar: Bool = true
    var body: some Scene {
        MenuBarExtra("Zeno", image: .zenoLogo, isInserted: $showStatusBar) {
            ContentView()
        }.menuBarExtraStyle(.window)
    }
}
