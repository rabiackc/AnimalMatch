//
//  RegisterView.swift
//  AnimalMatchGame
//
//  Created by Rabia Çakıcı on 21.07.2025.
//

import SwiftUI
import FirebaseAuth

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @Binding var isLoggedIn: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Image("arkaplan")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            Color.black.opacity(0.3).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("Yeni Hesap Oluştur")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .frame(width: 300)
                
                SecureField("Şifre", text: $password)
                    .padding()
                    .background(Color.white.opacity(0.9))
                    .cornerRadius(12)
                    .frame(width: 300)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .frame(width: 300)
                }
                
                Button(action: registerUser) {
                    Text("Kayıt Ol")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 250)
                        .background(Color.green)
                        .cornerRadius(15)
                }
            }
            .padding()
            .navigationTitle("Kayıt Ol")
        }
    }
    
    private func registerUser() {
        errorMessage = ""
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error = error {
                errorMessage = "Hata: \(error.localizedDescription)"
            } else {
                isLoggedIn = true
                dismiss()
            }
        }
    }
}
