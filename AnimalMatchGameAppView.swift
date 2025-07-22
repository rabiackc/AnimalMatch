//
//  AnimalMatchGameAppView.swift
//  AnimalMatchGame
//
//  Created by Rabia Çakıcı on 21.07.2025.
//

import Foundation
import SwiftUI
import FirebaseCore

@main
struct AnimalMatchGameApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
