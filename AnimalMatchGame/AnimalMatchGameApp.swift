//
//  AnimalMatchGameApp.swift
//  AnimalMatchGame
//
//  Created by Rabia Çakıcı on 8.07.2025.
//



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
