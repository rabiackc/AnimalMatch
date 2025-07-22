//
//  ContentView.swift
//  AnimalMatchGame
//
//  Created by Rabia Çakıcı on 21.07.2025.
//

import SwiftUI
import FirebaseAuth

// Kartın veri modeli
struct Card: Identifiable {
    let id = UUID()
    let name: String // Bu artık resim asset adını tutacak
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
    @State private var isGameOver = false // Yeni: Oyunun bittiğini kontrol eden değişken
    @State private var timeRemaining = 60 // Süreli oyun için
    private var timer: Timer? // Süreli oyun için
    
    // Resim asset isimleri. Buraya 'Assets.xcassets'e eklediğiniz resimlerin adlarını yazın.
    private let cardImageNames = ["bear", "fox", "rabbit", "lion", "elephant", "giraffe"] // Örnek isimler, kendi resimlerinize göre güncelleyin
    
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
                        Text("Süre: \(timeRemaining)s") // Süre göstergesi
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
                            isGameOver = false // Oyuna başlarken bitiş durumunu sıfırla
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    } else if isGameOver { // Oyun bittiğinde gösterilecek ekran
                        GameOverView(score: score) {
                            // Yeniden başlatma aksiyonu
                            gameStarted = false
                            isGameOver = false
                            // setupGame() // setupGame'i doğrudan çağırmak yerine, gameStarted'ı false yaparak başlama butonunu gösterelim.
                        }
                    }
                    else { // Oyun devam ederken
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
            // Giriş ve Kayıt Ekranı (Değişiklik yapılmadı)
            NavigationStack {
                ZStack {
                    Image("arkaplan")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                        .opacity(0.8)
                    
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
        // Zamanlayıcıyı sıfırla ve başlat
        timer?.invalidate() // Önceki zamanlayıcıyı durdur
        timeRemaining = 60
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                endGame() // Süre bittiğinde oyunu bitir
            }
        }
        
        // Oyun durumunu sıfırla
        flippedCards = []
        matchedCardsCount = 0
        score = 0
        isGameOver = false
        
        // Kart içeriklerini oluştur (her resimden 2 tane)
        var gameCardContents: [String] = []
        for _ in 0..<2 { // Her resimden 2 tane olmalı
            gameCardContents.append(contentsOf: cardImageNames)
        }
        gameCardContents.shuffle()
        
        cards = gameCardContents.map { name in
            Card(name: name, isFlipped: true) // Başlangıçta tüm kartlar açık
        }
        
        // Kartları 3 saniye sonra ters çevir
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            for i in cards.indices {
                cards[i].isFlipped = false
            }
        }
    }
    
    private func flipCard(at index: Int) {
        // Oyun bitmişse veya kart zaten açıksa/eşleşmişse veya iki kart zaten çevriliyse işlem yapma
        if isGameOver || cards[index].isFlipped || cards[index].isMatched || flippedCards.count == 2 { return }
        
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
            // Eşleşme bulundu
            for i in cards.indices {
                if cards[i].id == flippedCards[0].id || cards[i].id == flippedCards[1].id {
                    cards[i].isMatched = true
                    cards[i].isFlipped = true // Eşleşme bulundu, kartı açık tut
                }
            }
            score += 10
            matchedCardsCount += 2
            
            // Tüm kartlar eşleşti mi kontrol et
            if matchedCardsCount == cards.count {
                endGame() // Tüm kartlar eşleştiğinde oyunu bitir
            }
        } else {
            // Eşleşme yok
            for i in cards.indices {
                if cards[i].id == flippedCards[0].id || cards[i].id == flippedCards[1].id {
                    cards[i].isFlipped = false // Eşleşme yok, kartı geri çevir
                }
            }
        }
        flippedCards.removeAll()
    }
    
    // Oyunun bitişini yöneten fonksiyon
    private func endGame() {
        timer?.invalidate() // Zamanlayıcıyı durdur
        isGameOver = true // Oyun bitti durumunu ayarla
    }
}

// Yardımcı görünüm: Kartın kendisi (değişiklik yapılmadı)
struct CardView: View {
    @Binding var card: Card
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(card.isMatched ? Color.clear : Color.white)
                .shadow(radius: 5)
            
            if card.isFlipped {
                Image(card.name) // Resim asset adını kullan
                    .resizable()
                    .scaledToFit()
                    .padding(5)
                    .transition(.scale)
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.purple) // Kartın arka yüzü
            }
        }
        .aspectRatio(2/3, contentMode: .fit)
    }
}

// Yeni: Oyun bittiğinde gösterilecek özel görünüm
struct GameOverView: View {
    let score: Int
    let onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Oyun Bitti!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text("Son Skorunuz: \(score)")
                .font(.title2)
                .foregroundColor(.black)
            
            Button(action: onRestart) {
                Text("Tekrar Oyna")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding(40)
        .background(Color.white.opacity(0.95))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding()
    }
}


// Önizleme
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
