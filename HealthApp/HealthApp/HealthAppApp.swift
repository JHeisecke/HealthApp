//
//  HealthAppApp.swift
//  HealthApp
//
//  Created by Javier Heisecke on 2024-09-15.
//

import SwiftUI

@main
struct HealthAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(healthKit: HealthKitManager())
        }
    }
}
