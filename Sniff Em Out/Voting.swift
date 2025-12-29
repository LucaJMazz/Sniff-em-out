//
//  Voting.swift
//  Sniff Em Out
//
//  Created by Luca Mazzotta on 2025-01-22.
//
import SwiftUI

struct Voting: View {
    var onStartGame: () -> Void // Callback for starting the game
    @State private var playerNames: [String] = PlayerHandler.shared.getPlayerNames();
    @State private var playerAmount: Int = PlayerHandler.shared.getPlayerAmount();
    
    @State private var selectedName: Int = -1
    @State private var counter = 0;
    @State private var votedPlayer = 0;
    @State private var votesAmount: [Int] = Array(repeating: 0, count: PlayerHandler.shared.getPlayerAmount())
    
    @State private var circleScale: CGFloat = 0.0 // Scale of the circle for the transition
    @State private var animationOffsets: [CGFloat] = [700.0, 0.0, 0.0, 0.0, 0.0, 700.0, 180.0, 0.0 ,0.0];
    
    @State private var voteButtonImage: String = "Button";
    @State private var voteButtonVert: CGFloat = 0;
    @State private var winnersFileImage: String = "MoleWinsFile";
    
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
                
                Text("voting")
                    .font(.custom("ProhibitionTest-RoughOblique", size: 96))
                    .foregroundStyle(Color.white)
                    .offset(y: -9)
            }
            .offset(y: -UIScreen.main.bounds.height / 2 + 100)
            
            // ForeGround
            VStack {
                Spacer()
                let player = PlayerHandler.shared.getPlayer(index: counter)
                Text("\(player)")
                    .font(.custom("ProhibitionTest-RoughOblique", size: 55))
                    .foregroundStyle(Color.white)
                    .lineSpacing(-10)
                    .offset(y:10)
                
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
                .frame(width: UIScreen.main.bounds.width - 45, height: 400)
                .shadow(radius: 5, y: 8)
                .offset(y: 0)

                    //Vote Button
                    ZStack{
                        Image(voteButtonImage)
                            .resizable()
                            .frame(width: 240.0, height: 140.0)
                            .gesture(DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if value.startLocation == value.location {
                                        voteButtonPress()
                                    }
                                }
                                .onEnded { _ in
                                    voteButtonRelease()
                                }
                            )
                        Text("Vote")
                            .font(.custom("ProhibitionTest-Regular", size: 43))
                            .padding(.bottom, 39.0)
                            .foregroundStyle(.black)
                            .allowsHitTesting(false) // Ignore user interactions
                    }
                    .offset(y: voteButtonVert)
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
                        
                        Text("\(playerNames[votedPlayer]) was voted out")
                            .font(.custom("ProhibitionTest-Regular", size: 40))
                            .foregroundStyle(.black)
                            .scaleEffect(CGFloat(animationOffsets[2]))
                        
                        Text("they were...")
                            .font(.custom("ProhibitionTest-Regular", size: 40))
                            .foregroundStyle(.black)
                            .scaleEffect(CGFloat(animationOffsets[3]))
                        
                        let role = PlayerHandler.shared.getRoleString(index: votedPlayer);
                        Text("\(role)")
                            .font(.custom("ProhibitionTest-Regular", size: 60))
                            .foregroundStyle(.black)
                            .scaleEffect(CGFloat(animationOffsets[4]))
                        
                        Spacer()
                    }
                    .frame(width: UIScreen.main.bounds.width-60, height: 485.0)
                    
                }
                .offset(y:animationOffsets[0])
                
                
                Image(winnersFileImage)
                    .frame(height: 0)
                    .scaleEffect(0.51)
                    .offset(x:15)
                    .rotationEffect(Angle(degrees: animationOffsets[6]))
                    .offset(y:animationOffsets[5])
                    .offset(y:20)
                
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
        var name = PlayerHandler.shared.getPlayer(index: index)
        if name == "" {
            name = "Player \(index + 1)"
        }
        return Button {
            print("Clicked")
            selectedName = index
        } label: {
            Text(name)
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
        return index == selectedName ? false : true;
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
            withAnimation(.bouncy(duration: 0.3)) { // __ Voted Out
                animationOffsets[2] = 1.0;
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.bouncy(duration: 0.3)) { // __ Voted Out
                    animationOffsets[3] = 1.0;
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                    withAnimation(.bouncy(duration: 0.3)) { // __ Voted Out
                        animationOffsets[4] = 1.0;
                    }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            withAnimation(.easeInOut(duration: 0.6)) { // __ Voted Out
                animationOffsets[5] = 0.0;
            }
            withAnimation(.easeInOut(duration: 0.6)) { // __ Voted Out
                animationOffsets[6] = 360.0;
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                animationOffsets[7] = 1.0;
                withAnimation(.bouncy(duration: 0.3)) { // __ Voted Out
                    animationOffsets[8] = 1.0;
                }
            }
        }
    }
    
    func voteButtonPress(){
        voteButtonImage = "Button_Press";
        voteButtonVert = 5.0;
    }
    func voteButtonRelease(){
        voteButtonImage = "Button";
        voteButtonVert = 0;
        
        if(selectedName != -1){
            votesAmount[selectedName] += 1;
        }
        counter+=1;
        if (counter == playerAmount){
            counter = 0;
            votedPlayer = 0;
            for i in 0..<playerAmount {
                if (votesAmount[i] > votesAmount[votedPlayer]){
                    votedPlayer = i;
                }
            }
            
            if (PlayerHandler.shared.getRoleIndex(index: votedPlayer) == 3) {
                winnersFileImage = "AssociatesWinFile";
            }
            
            resultsAnimation()
        }
        
        selectedName = -1;
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
    Voting(onStartGame: {})
}
