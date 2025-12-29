//
//  MainMenu.swift
//  Sniff Em Out
//
//  Created by Luca Mazzotta on 2025-01-17.
//

import SwiftUI

struct MainMenu: View {
    var onStartGame: () -> Void // Callback for starting the game
    
    @State var circleScale: CGFloat = 0.0 // Scale of the circle for the transition
    
    @State var playButtonImage: String = "Button";
    @State var playButtonVert: CGFloat = 0;
    
    @State var instructionsButtonImage: String = "Button";
    @State var instructionsButtonVert: CGFloat = 0;
    
    @State var instructionsDisplayed: Bool = false;
    
    @State private var animationOffsets: [CGFloat] = [0.0 ,0.0, 0.0, 700.0];
    
    var body: some View {
        ZStack{
            //BackGround
            Image("BG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            //ForeGround
            VStack{
                Image("MenuIcon")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: 380)
                    .padding()
                
                VStack{
                    //Play Button
                    ZStack{
                        Image(playButtonImage)
                            .gesture(DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if value.startLocation == value.location {
                                        playButtonPress()
                                    }
                                }
                                .onEnded { _ in
                                    // Handle release action (when the touch ends)
                                    playButtonRelease()
                                }
                            )
                        Text("Play")
                            .font(.custom("ProhibitionTest-Regular", size: 56))
                            .padding(.bottom, 45.0)
                            .foregroundStyle(.black)
                            .allowsHitTesting(false) // Ignore user interactions
                    }
                    .offset(y: playButtonVert)
                    .scaleEffect(animationOffsets[0])
                    
                    //Instructions Button
                    ZStack{
                        Image(instructionsButtonImage)
                            .resizable()
                            .frame(width: 250.0, height: 120.0)
                            .gesture(DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if value.startLocation == value.location {
                                        instructionsButtonPress()
                                    }
                                }
                                .onEnded { _ in
                                    // Handle release action (when the touch ends)
                                    instructionsButtonRelease()
                                }
                            )
                        Text("Instructions")
                            .font(.custom("ProhibitionTest-Regular", size: 32))
                            .padding(.bottom, 32.0)
                            .foregroundStyle(.black)
                            .allowsHitTesting(false) // Ignore user interactions
                    }
                    .offset(y: -20.0)
                    .offset(y: instructionsButtonVert)
                    .scaleEffect(animationOffsets[1])
                }
            }
            
            //Instruction panel
            ZStack{
                VisualEffectView(effect: UIBlurEffect(style: .dark))
                    .ignoresSafeArea(edges: .all)
                    .opacity(animationOffsets[2])
                
                Group{
                    Rectangle()
                        .fill(Color.whiteColour)
                        .cornerRadius(20.0)
                        .frame(width: UIScreen.main.bounds.width-50, height: 500.0)
                        .shadow(
                            color: .black.opacity(100),
                            radius: 15.0,
                            x: 0.0, y: 7.0)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            instructionsText()
                        }
                        .foregroundStyle(.black)
                    }
                    .frame(width: UIScreen.main.bounds.width-70, height: 480.0)
                    .clipped()
                    Button(action: {
                        
                        withAnimation(.bouncy(duration: 0.7)) { // Rectangle
                            animationOffsets[3] = 700.0;
                        }
                        withAnimation(.easeIn(duration: 0.3)) { // Blur
                            animationOffsets[2] = 0.0;
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            instructionsDisplayed = false
                        }
                        
                    }) {
                        Label("", systemImage: "xmark.circle")
                    }
                    .frame(width: 50, height: 50)
                    .position(x: (UIScreen.main.bounds.width - 50 + 10), y: (UIScreen.main.bounds.height)/2 - 250 - 10)
                    .foregroundStyle(.black)
                }
                .offset(y: animationOffsets[3])
            }
            .opacity(instructionsDisplayed ? 1 : 0)
            
            //Circle Wipe Transition
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
            openingAnimations() // Start the animation when the view appears
        }
    }
    
    func playButtonPress(){
        playButtonImage = "Button_Press";
        playButtonVert = 5.0;
    }
    func playButtonRelease(){
        playButtonImage = "Button";
        playButtonVert = 0;
        animateCircleShrink();
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            onStartGame()
        }
    }
    func instructionsButtonPress(){
        instructionsButtonImage = "Button_Press";
        instructionsButtonVert = 4.0;
    }
    func instructionsButtonRelease(){
        instructionsButtonImage = "Button";
        instructionsButtonVert = 0;
        
        withAnimation(.bouncy(duration: 0.7)) { // Rectangle
            animationOffsets[3] = 0.0;
        }
        withAnimation(.easeIn(duration: 0.3)) { // Blur
            animationOffsets[2] = 1.0;
        }
        
        instructionsDisplayed = true;
        
    }
    
    func animateCircleShrink() {
        withAnimation(.easeOut(duration: 0.7)) { // 500ms animation
            circleScale = 0.0 // Shrink the circle to zero
        }
        SoundManager.instance.playSound(sound: .vibraphone, volume: 0.5);
    }
    
    func openingAnimations() {
        withAnimation(.easeIn(duration: 0.7)) { // 500ms animation
            circleScale = 3.0 // Shrink the circle to zero
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            SoundManager.instance.playSound(sound: .jazz_opening, volume: 0.7);
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation(.bouncy(duration: 0.4)) { // Bounce Play Button
                animationOffsets[0] = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.bouncy(duration: 0.4)) { // Bounce Play Button
                    animationOffsets[1] = 1.0
                }
            }
        }
    }
    
    func instructionsText() -> some View {
        return Group{
            Text("How to Play:")
                .font(.custom("ProhibitionTest-Regular", size: 40))
            Text("                                                                                                                                                          ")
                .font(.custom("ProhibitionTest-Regular", size: 10))
            Text("Sniff em Out is a party game where players take turns asking questions and trying to figure out who is the mole. \n\nEveryone is given a topic (the clue) except for the player who is \"The Mole\" who has no idea what the clue is. Players then take turns answering open-ended questions about the topic to provide hints, while the mole tries to blend in and avoid being identified. \n\nAt the end of the round, everyone votes on who they think the mole is, and the mole can redeem themselves by correctly guessing the secret topic or evading suspicion.")
                .font(.custom("ProhibitionTest-Regular", size: 22))
                .multilineTextAlignment(.leading)
            Text("Roles:\nAssociate:")
                .font(.custom("ProhibitionTest-Regular", size: 35))
                .multilineTextAlignment(.leading)
            Text("An Associate plays the role of a trusted confidant who knows the details of the secret clue. Their goal is to subtly guide the discussion, answering questions or providing hints that align with the mystery without revealing too much to the outsider. They must maintain composure and avoid being too obvious, as their responses could give away the clue or make the detective suspicious of their knowledge. Their success relies on balancing helpfulness to the group and discretion to protect the integrity of the investigation. ")
                .font(.custom("ProhibitionTest-Regular", size: 25))
                .multilineTextAlignment(.leading)
            Text("\nDetective:")
                .font(.custom("ProhibitionTest-Regular", size: 35))
                .multilineTextAlignment(.leading)
            Text("The Detective is just an Associate with extra qualities. They still play the role of the Associate, but, during the voting, the detective's vote counts as 2 votes. This gives the detective player more responsibility and a chance to make more of a difference in the game.")
                .font(.custom("ProhibitionTest-Regular", size: 25))
                .multilineTextAlignment(.leading)
            Text("\nMole:")
                .font(.custom("ProhibitionTest-Regular", size: 35))
                .multilineTextAlignment(.leading)
            Text("The Mole is the player who is unaware of the secret clue. Their job is to blend in and act as though they are fully informed, carefully answering questions and contributing to the discussion without revealing their lack of knowledge. The Mole must use observation, deduction, and quick thinking to mimic the behavior and reasoning of the other players while steering suspicion away from themselves. If successful, the mole evades detection or even guesses the secret clue, proving their cunning deception skills.")
                .font(.custom("ProhibitionTest-Regular", size: 25))
                .multilineTextAlignment(.leading)
        }
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

#Preview {
    MainMenu(onStartGame: {})
}
