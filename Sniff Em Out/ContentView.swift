//
//  ContentView.swift
//  Sniff Em Out
//
//  Created by Luca Mazzotta on 2025-01-16.
//

import SwiftUI

struct ContentView: View {
    @State private var currentView: ViewType = .mainMenu // Default view is MainMenu
    
    var body: some View {
        ZStack { // Using ZStack as a wrapper for the views
            switch currentView {
            case .mainMenu:
                MainMenu(onStartGame: {
                    currentView = .playerSelect
                })
            case .playerSelect:
                PlayerSelect(onStartGame: {
                    currentView = .categories
                })
            case .categories:
                Categories(onStartGame: {
                    currentView = .assignment
                })
            case .assignment:
                Assignment(onStartGame: {
                    currentView = .question
                },
                topic: CategoryHandler.shared.getSelectedItem())
            case .question:
                Question(onStartGame: {
                    currentView = .voting
                })
            case .voting:
                Voting(onStartGame: {
                    currentView = .guess
                })
            case .guess:
                Guess(onStartGame: {
                    currentView = .mainMenu
                })
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
                SoundManager.instance.playBackgroundMusic()
            }
        }
    }
}


enum ViewType {
    case mainMenu
    case playerSelect
    case categories
    case assignment
    case question
    case voting
    case guess
}

#Preview {
    ContentView()
}
