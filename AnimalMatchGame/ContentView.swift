//
//  ContentView.swift
//  AnimalMatchGame
//
//  Created by Rabia Çakıcı on 8.07.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            // Resimli arkaplan
            Image("arkaplan")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Arkaplan üstü şeffaf renk efekti 
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Text("🦁 Kart Oyunu 🐘")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .frame(width: 300)
                    .font(.title2)

                SecureField("Şifre", text: $password)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .frame(width: 300)
                    .font(.title2)

                Button(action: {
                    print("Email: \(email), Şifre: \(password)")
                }) {
                    Text("🎮 Sing Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 250)
                        .background(Color.pink)
                        .cornerRadius(15)
                }

                Button {
                    //login
                } label: {
                    Text("Already have an account? Log in")
                        .bold()
                        .foregroundStyle(.white)
                        
                }
                
                Spacer()
            }
            .padding(.top, 60)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

