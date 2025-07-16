//
//  ContentView.swift
//  AnimalMatchGame
//
//  Created by Rabia Çakıcı on 8.07.2025.
//


import SwiftUI
import FirebaseAuth

// Kartın veri modeli
struct Card: Identifiable {
    let id = UUID()
    let name: String
    var isFlipped: Bool = false
    var isMatched: Bool = false
}

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    // Oyunla ilgili tüm durum değişkenleri
    @State private var cards: [Card] = []
    @State private var flippedCards: [Card] = []
    @State private var matchedCardsCount = 0
    @State private var score = 0
    @State private var gameStarted = false
    
    private let cardNames = ["bear", "fox", "rabbit", "lion", "elephant", "bear", "fox", "rabbit", "lion", "elephant"]
    
    var body: some View {
        // isLoggedIn durumuna göre görünümü yöneten ana blok
        if isLoggedIn {
            // Oyun Ekranı
            NavigationStack {
                VStack {
                    HStack {
                        Text("Skor: \(score)")
                            .font(.title).bold()
                        Spacer()
                        Button("Çıkış Yap") { signOut() }
                            .buttonStyle(.bordered).tint(.red)
                    }
                    .padding()
                    
                    if !gameStarted {
                        Button("Oyunu Başlat") {
                            setupGame()
                            gameStarted = true
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    } else {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4)) {
                            ForEach(cards.indices, id: \.self) { index in
                                CardView(card: $cards[index])
                                    .onTapGesture {
                                        flipCard(at: index)
                                    }
                            }
                        }
                        .padding()
                    }
                    
                    Spacer()
                }
                .navigationTitle("Kart Oyunu")
            }
        } else {
            // Giriş ve Kayıt Ekranı
            NavigationStack {
                ZStack {
                    Image("arkaplan")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    Color.black.opacity(0.3).ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Text("🐻 Kart Oyunu 🦊")
                            .font(.system(size: 40, weight: .bold, design: .rounded))
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
                        
                        Button(action: signIn) {
                            Text("🎮 Giriş Yap")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 250)
                                .background(Color.pink)
                                .cornerRadius(15)
                        }
                        
                        NavigationLink(destination: RegisterView(isLoggedIn: $isLoggedIn)) {
                            Text("📝 Kayıt Ol")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: 250)
                                .background(Color.purple)
                                .cornerRadius(15)
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 60)
                }
            }
        }
    }
    
    // Yardımcı fonksiyonlar
    private func signIn() {
        errorMessage = ""
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                errorMessage = "Giriş Hatası: \(error.localizedDescription)"
            } else {
                isLoggedIn = true
            }
        }
    }
    
    private func signOut() {
        do {
            try Auth.auth().signOut()
            isLoggedIn = false
        } catch {
            print("Çıkış yapma hatası: \(error.localizedDescription)")
        }
    }
    
    private func setupGame() {
        let shuffledCards = cardNames.shuffled()
        cards = shuffledCards.map { name in
            Card(name: name, isFlipped: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            for i in cards.indices {
                cards[i].isFlipped = false
            }
        }
    }
    
    private func flipCard(at index: Int) {
        if cards[index].isFlipped || cards[index].isMatched || flippedCards.count == 2 { return }
        
        cards[index].isFlipped = true
        flippedCards.append(cards[index])
        
        if flippedCards.count == 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                checkMatch()
            }
        }
    }
    
    private func checkMatch() {
        if flippedCards[0].name == flippedCards[1].name {
            for i in cards.indices {
                if cards[i].id == flippedCards[0].id || cards[i].id == flippedCards[1].id {
                    cards[i].isMatched = true
                    cards[i].isFlipped = true
                }
            }
            score += 10
            matchedCardsCount += 2
        } else {
            for i in cards.indices {
                if cards[i].id == flippedCards[0].id || cards[i].id == flippedCards[1].id {
                    cards[i].isFlipped = false
                }
            }
        }
        flippedCards.removeAll()
    }
}

// Yardımcı görünüm
struct CardView: View {
    @Binding var card: Card
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(card.isMatched ? Color.clear : Color.white)
                .shadow(radius: 5)
            
            if card.isFlipped {
                Text(card.name)
                    .font(.largeTitle)
                    .transition(.scale)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.purple)
            }
        }
        .aspectRatio(2/3, contentMode: .fit)
    }
}

// Önizleme
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
