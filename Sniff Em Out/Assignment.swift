//
//  Assignment.swift
//  Sniff Em Out
//
//  Created by Luca Mazzotta on 2025-01-20.
//

import SwiftUI

struct Assignment: View {
    var onStartGame: () -> Void // Callback for starting the game
    let topic: String
    
    @State var circleScale: CGFloat = 0.0 // Scale of the circle for the transition
    @State var slideOffsetY: CGFloat = 0.0 // Slide for casefile animation
    @State var counter = 0;
    @State var textSizeAnimation = 0.0;
    
    var body: some View {
        ZStack{
            //BackGround
            Image("BG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            // Banner
            ZStack {
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width, height: 185)
                    .foregroundStyle(Color.accentColor)
                    .shadow(radius: 5, y: 8)
                
                VStack(spacing: -15) { // Negative spacing between lines
                    Text("Pass the")
                        .font(.custom("ProhibitionTest-RoughOblique", size: 85))
                        .foregroundStyle(Color.white)
                        .lineSpacing(-10)
                        .offset(y: -9)
                    Text("Phone to")
                        .font(.custom("ProhibitionTest-RoughOblique", size: 85))
                        .foregroundStyle(Color.white)
                        .lineSpacing(-10)
                        .offset(y: -9)
                }
            }
            .offset(y: -UIScreen.main.bounds.height / 2 + 145)
            
            //ForeGround
            VStack{
                Spacer()
                let player = getPlayerAssignmentString(index: counter)
                Text("\(player[0])")
                    .font(.custom("ProhibitionTest-RoughOblique", size: 55))
                    .foregroundStyle(Color.white)
                    .lineSpacing(-10)
                    .offset(y:10)
                    .scaleEffect(textSizeAnimation)
                
                ZStack{
                    Image("YouArePaper")
                        .resizable()
                        .frame(width: 656.0/1.75, height: 856.0/1.78)
                        .offset(x:15)
                        .gesture(
                            TapGesture()
                                .onEnded { // Executes when the tap gesture ends
                                    if counter < PlayerHandler.shared.getPlayerAmount()-1 {
                                        animateSlideCaseFileInverse()
                                    } else {
                                        nextScreen()
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                                        if counter < PlayerHandler.shared.getPlayerAmount()-1 {
                                            counter += 1
                                            
                                        }
                                    }
                                }
                        )
                        .overlay(
                            assignTextDisplay(roleString: player[1])
                            .offset(y:-40)
                        )
                    
                    Image("CaseFileAssign")
                        .resizable()
                        .frame(width: 656.0/1.75, height: 856.0/1.78)
                        .offset(x:15)
                        .gesture(
                            TapGesture()
                                .onEnded { // Executes when the tap gesture ends
                                    animateSlideCaseFile();
                                }
                        )
                        .offset(y:slideOffsetY)
                    
                }
                
            }
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
            animateCircleGrow() // Start the animation when the view appears
            animateNameText()
        }
    }
    
    func getPlayerAssignmentString(index: Int) -> [String] {
        var assignment:[String] = ["", ""]
        
        assignment[0] = PlayerHandler.shared.getPlayer(index: index)
        assignment[1] = PlayerHandler.shared.getRoleString(index: index)
        
        return assignment
    }
    
    func assignTextDisplay(roleString: String) -> some View {
        VStack{
            Text(roleString)
                .font(.custom("ProhibitionTest-RoughOblique", size: 45))
                .foregroundStyle(Color.accentColor)
            
            if roleString != "The Mole"{
                Text("Clue:")
                    .font(.custom("ProhibitionTest-Rough", size: 38))
                    .foregroundStyle(Color.accentColor)
                Text("\(topic)")
                    .font(.custom("ProhibitionTest-Rough", size: 30))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 200)
            }
        }
        .allowsHitTesting(false) // Ignore user interactions
    }
    
    func animateSlideCaseFile() {
        withAnimation(.easeIn(duration: 0.7)) {
            slideOffsetY = UIScreen.main.bounds.height
        }
    }
    func animateSlideCaseFileInverse() {
        withAnimation(.bouncy(duration: 0.7)) {
            slideOffsetY = 0
        }
        animateNameText()
    }
    
    func animateNameText() {
        withAnimation(.bouncy(duration: 0.3)) {
            textSizeAnimation = 0.0;
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.bouncy(duration: 0.3)) {
                textSizeAnimation = 1.0;
            }
        }
    }
    
    func animateCircleShrink() {
        withAnimation(.easeOut(duration: 0.7)) { // 500ms animation
            circleScale = 0.0 // Shrink the circle to zero
        }
    }
    
    func animateCircleGrow() {
        withAnimation(.easeIn(duration: 0.7)) { // 500ms animation
            circleScale = 3.0 // Shrink the circle to zero
        }
    }
    
    func nextScreen() {
        animateCircleShrink()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            onStartGame()
        }
    }
}


#Preview {
    Assignment(
        onStartGame: {},
        topic: "SpongeBob SquarePants" // Provide a sample topic for preview mode
    )
}
