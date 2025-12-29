//
//  PlayerSelect.swift
//  Sniff Em Out
//
//  Created by Luca Mazzotta on 2025-01-17.
//

import SwiftUI

struct PlayerSelect: View {
    var onStartGame: () -> Void // Callback for starting the game
    @State private var playerNames: [String] = PlayerHandler.shared.getPlayerNames();
    @State private var playerAmount: Int = PlayerHandler.shared.getPlayerAmount();
    
    @State var circleScale: CGFloat = 0.0 // Scale of the circle for the transition
    
    @State var readyButtonImage: String = "Button";
    @State var readyButtonVert: CGFloat = 0;
    
    var body: some View {
        ZStack {
            // BackGround
            Image("BG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            // Banner
            ZStack {
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width, height: 110)
                    .foregroundStyle(Color.accentColor)
                    .shadow(radius: 5, y: 8)
                
                Text("Players")
                    .font(.custom("ProhibitionTest-RoughOblique", size: 96))
                    .foregroundStyle(Color.white)
                    .offset(y: -9)
            }
            .offset(y: -UIScreen.main.bounds.height / 2 + 100)
            
            // ForeGround
            VStack {
                ScrollView(.vertical) {
                    VStack(spacing: 15) {
                        ForEach(0...playerAmount-1, id: \.self) { index in
                            nameFields(index: index)
                        }

                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.vertical, 18.0)
                .padding(.horizontal, 16.0)
                .background(Color.accentColor.opacity(0.4))
                .cornerRadius(20)
                .frame(width: UIScreen.main.bounds.width - 45, height: 490)
                .shadow(radius: 5, y: 8)
                .offset(y: 90)
                
                HStack {
                    //Add Button
                    ZStack{
                        Image("Add New")
                            .resizable()
                            .frame(width: 56.0, height: 56.0)
                            .gesture(DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    
                                }
                                .onEnded { _ in
                                    playerAmount+=1;
                                    playerNames.append("")
                                    PlayerHandler.shared.addPlayer()
                                    updatePlayerNames()
                                }
                            )
                    }
                    
                    //Ready Button
                    ZStack{
                        Image(readyButtonImage)
                            .resizable()
                            .frame(width: 240.0, height: 140.0)
                            .gesture(DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if value.startLocation == value.location {
                                        readyButtonPress()
                                    }
                                }
                                .onEnded { _ in
                                    readyButtonRelease()
                                }
                            )
                        Text("Ready")
                            .font(.custom("ProhibitionTest-Regular", size: 43))
                            .padding(.bottom, 39.0)
                            .foregroundStyle(.black)
                            .allowsHitTesting(false) // Ignore user interactions
                    }
                    .offset(y: readyButtonVert)
                    
                    
                    //Subtract Button
                    ZStack{
                        Image("Negative")
                            .resizable()
                            .frame(width: 56.0, height: 56.0)
                            .gesture(DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    
                                }
                                .onEnded { _ in
                                    playerAmount-=1;
                                    playerNames.removeLast()
                                    PlayerHandler.shared.removeLastPlayer()
                                    updatePlayerNames()
                                }
                            )
                    }
                }
                .offset(y:90)
            }
            
            // Circle Wipe Transition
            Rectangle()
                .fill(Color.black) // Full-screen black overlay
                .overlay(
                    Circle()
                        .scaleEffect(circleScale)
                        .blendMode(.destinationOut) // Subtract the circle from the rectangle
                )
                .compositingGroup() // Ensures blendMode works correctly
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false) // Ignore user interactions
        }
        .onAppear {
            animateCircleGrow() // Start the animation when the view appears
        }
        
    }
    
    func nameFields(index: Int) -> some View {
        let playerNameBinding = Binding(
            get: { playerNames[index] },
            set: { playerNames[index] = $0}
        )
        return TextField("Enter Name", text: playerNameBinding)
            .font(.custom("ProhibitionTest-Regular", size: 30))
            .foregroundStyle(Color.accentColor)
            .padding(.leading, 10)
            .frame(width: UIScreen.main.bounds.width - 45 - 30, height: 50)
            .background(Color.whiteColour)
            .cornerRadius(10)
            .autocorrectionDisabled(true)
    }
    
    func readyButtonPress(){
        readyButtonImage = "Button_Press";
        readyButtonVert = 5.0;
    }
    func readyButtonRelease(){
        readyButtonImage = "Button";
        readyButtonVert = 0;
        animateCircleShrink();
        PlayerHandler.shared.setPlayerNames(playerNames);
        PlayerHandler.shared.setPlayerAmount(amount: playerNames.count);
        PlayerHandler.shared.assignRoles() 
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            onStartGame()
        }
    }
    
    func updatePlayerNames() {
        PlayerHandler.shared.setPlayerNames(playerNames);
    }
    
    func animateCircleGrow() {
        withAnimation(.easeIn(duration: 0.7)) {
            circleScale = 3.0 // Grow the circle
        }
    }
    
    func animateCircleShrink() {
        withAnimation(.easeOut(duration: 0.7)) {
            circleScale = 0.0 // Shrink the circle
        }
    }
}

#Preview {
    PlayerSelect(onStartGame: {})
}
