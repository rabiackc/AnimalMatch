//
//  ContentView.swift
//  AnimalMatchGame
//
//  Created by Rabia Çakıcı on 8.07.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var username: String = ""
    @State private var isLoggedIn = false

    var body: some View {
        NavigationView {
            if isLoggedIn {
                // Ana Menü
                VStack(spacing: 40) {
                    Text("🃏 Kart Oyunu")
                        .font(.largeTitle)
                        .bold()
                        .padding()

                    Text("Hoş geldin, \(username)!")
                        .font(.title2)
                        .foregroundColor(.gray)

                    NavigationLink(destination: Text("🎮 Oyun Ekranı")) {
                        Text("🎮 Oyuna Başla")
                            .font(.title2)
                            .frame(width: 220, height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    NavigationLink(destination: Text("📜 Kurallar:\nKart çek, eşleş, kazan!").padding()) {
                        Text("📜 Kurallar")
                            .font(.title2)
                            .frame(width: 220, height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        exit(0)
                    }) {
                        Text("🚪 Çıkış")
                            .font(.title2)
                            .frame(width: 220, height: 50)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Spacer()
                }
                .navigationTitle("Ana Menü")
            } else {
                // Kullanıcı Girişi
                VStack(spacing: 30) {
                    Text("🃏 Kart Oyunu")
                        .font(.largeTitle)
                        .bold()
                        .padding()

                    TextField("Adınızı girin", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 40)

                    Button("Giriş Yap") {
                        if !username.isEmpty {
                            isLoggedIn = true
                        }
                    }
                    .font(.title2)
                    .frame(width: 220, height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)

                    Spacer()
                }
                .navigationTitle("Giriş Yap")
            }
        }
    }
}

#Preview {
    ContentView()
}
