//
//  Guess.swift
//  Sniff Em Out
//
//  Created by Luca Mazzotta on 2025-02-04.
//
import SwiftUI

struct Guess: View {
    var onStartGame: () -> Void // Callback for starting the game
    
    @State var selectedItem = 0;
    
    @State private var circleScale: CGFloat = 0.0 // Scale of the circle for the transition
    @State private var animationOffsets: [CGFloat] = [700.0, 0.0, 0.0, 0.0, 0.0, 700.0, 180.0, 0.0 ,0.0];
    
    @State private var randomIndexes: [Int] = {
        let max = CategoryHandler.shared.getArrayMaxLength()-1;
        let range = 1...max
        var shuffledNumbers = Array(range).shuffled()
        
        let rnum = Int.random(in: 0..<6)
        shuffledNumbers[rnum] = CategoryHandler.shared.getSelectedItemIndex();
        
        return Array(shuffledNumbers.prefix(6))
    }()
    
    @State private var guessButtonImage: String = "Button";
    @State private var guessButtonVert: CGFloat = 0;
    
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
                
                Text("guess")
                    .font(.custom("ProhibitionTest-RoughOblique", size: 96))
                    .foregroundStyle(Color.white)
                    .offset(y: -9)
            }
            .offset(y: -UIScreen.main.bounds.height / 2 + 100)
            
            // ForeGround
            VStack {
                Spacer()
                let player = PlayerHandler.shared.getMolesName()
                Text("\(player)")
                    .font(.custom("ProhibitionTest-RoughOblique", size: 55))
                    .foregroundStyle(Color.white)
                    .lineSpacing(-10)
                    .offset(y:10)
                
                ScrollView(.vertical) {
                    VStack(spacing: 15) {
                        ForEach(0...5, id: \.self) { index in
                            nameFields(index: index)
                        }

                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.vertical, 18.0)
                .padding(.horizontal, 16.0)
                .background(Color.accentColor.opacity(0.4))
                .cornerRadius(20)
                .frame(width: UIScreen.main.bounds.width - 45, height: 410)
                .shadow(radius: 5, y: 8)
                .offset(y: 0)

                    //Guess Button
                    ZStack{
                        Image(guessButtonImage)
                            .resizable()
                            .frame(width: 240.0, height: 140.0)
                            .gesture(DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if value.startLocation == value.location {
                                        guessButtonPress()
                                    }
                                }
                                .onEnded { _ in
                                    guessButtonRelease()
                                }
                            )
                        Text("Guess")
                            .font(.custom("ProhibitionTest-Regular", size: 43))
                            .padding(.bottom, 39.0)
                            .foregroundStyle(.black)
                            .allowsHitTesting(false) // Ignore user interactions
                    }
                    .offset(y: guessButtonVert)
                    .offset(y:0)
                

            }
            
            // Voting Results panel
            ZStack{
                VisualEffectView(effect: UIBlurEffect(style: .dark))
                    .ignoresSafeArea(edges: .all)
                    .opacity(animationOffsets[1])
                // Rectangle Group
                Group{
                    Rectangle()
                        .fill(Color.whiteColour)
                        .cornerRadius(20.0)
                        .frame(width: UIScreen.main.bounds.width-50, height: 500.0)
                        .shadow(
                            color: .black.opacity(100),
                            radius: 15.0,
                            x: 0.0, y: 7.0)
                    
                    VStack(spacing: 20.0) {
                        Text("Results:")
                            .font(.custom("ProhibitionTest-Regular", size: 75))
                            .foregroundStyle(.black)
                        let guessedItem = CategoryHandler.shared.getRandomItem(index:randomIndexes[selectedItem]);
                        Text("You guessed \(guessedItem)")
                            .font(.custom("ProhibitionTest-Regular", size: 40))
                            .foregroundStyle(.black)
                            .scaleEffect(CGFloat(animationOffsets[2]))
                        
                        Text("the correct answer was...")
                            .font(.custom("ProhibitionTest-Regular", size: 40))
                            .foregroundStyle(.black)
                            .scaleEffect(CGFloat(animationOffsets[3]))
                        
                        Text("\(CategoryHandler.shared.getSelectedItem())")
                            .font(.custom("ProhibitionTest-Regular", size: 50))
                            .foregroundStyle(.black)
                            .scaleEffect(CGFloat(animationOffsets[4]))
                        
                        Spacer()
                    }
                    .frame(width: UIScreen.main.bounds.width-60, height: 485.0)
                    
                }
                .offset(y:animationOffsets[0])

                Button {
                    nextScreen();
                } label: {
                    Text("Tap to continue")
                        .offset(y:320)
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill entire space
                        .font(.custom("ProhibitionTest-Regular", size: 35))
                        .foregroundStyle(Color.whiteColour)
                        .contentShape(Rectangle()) // Make entire frame tappable
                        .background(Color.clear) // Transparent background
                }
                .buttonStyle(PlainButtonStyle())
                .opacity(animationOffsets[7])
                .scaleEffect(animationOffsets[8])
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
        let item: String = CategoryHandler.shared.getRandomItem(index: randomIndexes[index])
        
        return Button {
            print("Clicked")
            selectedItem = index
        } label: {
            Text(item)
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill entire space
                .contentShape(Rectangle()) // Make entire frame tappable
                .background(Color.clear) // Transparent background
        }
        .frame(width: UIScreen.main.bounds.width - 45 - 30, height: 50)
        .foregroundStyle(Color.black)
        .background(isSelected(index: index) ? Color.whiteColour : Color.gray)
        .cornerRadius(10)
        .font(.custom("ProhibitionTest-Regular", size: 30))
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle()) // Crucial for hit testing
    }
    func isSelected(index: Int) -> Bool {
        return index == selectedItem ? false : true;
    }

    func resultsAnimation() {
        // Instant animations
        withAnimation(.bouncy(duration: 0.7)) { // Rectangle
            animationOffsets[0] = 0.0;
        }
        withAnimation(.easeIn(duration: 0.3)) { // Blur
            animationOffsets[1] = 1.0;
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.bouncy(duration: 0.3)) { // __ guessed Out
                animationOffsets[2] = 1.0;
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.bouncy(duration: 0.3)) { // __ guessed Out
                    animationOffsets[3] = 1.0;
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    withAnimation(.bouncy(duration: 0.3)) { // __ guessed Out
                        animationOffsets[4] = 1.0;
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        animationOffsets[7] = 1.0;
                        withAnimation(.bouncy(duration: 0.3)) { // __ guessed Out
                            animationOffsets[8] = 1.0;
                        }
                    }
                }
            }
        }
    }
    
    func guessButtonPress(){
        guessButtonImage = "Button_Press";
        guessButtonVert = 5.0;
    }
    func guessButtonRelease(){
        guessButtonImage = "Button";
        guessButtonVert = 0;
         
        resultsAnimation()
    }
    
    func nextScreen(){
        animateCircleShrink();
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            onStartGame()
        }
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
    
    
    struct VisualEffectView: UIViewRepresentable {
        var effect: UIVisualEffect?
        func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
        func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
    }
}


#Preview {
    Guess(onStartGame: {})
}

