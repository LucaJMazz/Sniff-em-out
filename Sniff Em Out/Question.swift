//
//  Question.swift
//  Sniff Em Out
//
//  Created by Luca Mazzotta on 2025-01-21.
//

import SwiftUI

struct Question: View {
    var onStartGame: () -> Void // Callback for starting the game
    
    let questionList: [[String]] = readFileIntoArray(fileName: "questionList", fileType: "txt")
  
    @State var topicIndex = 0;
    @State var rNum = 0;

    @State var circleScale: CGFloat = 0.0 // Scale of the circle for the transition
    @State var slideOffsetY: CGFloat = 0.0 // Slide for casefile animation
    @State var counter = 0;
    @State var repeatedCheck: Bool = false;
    
    @State var nextButtonImage: String = "Button";
    @State var nextButtonVert: CGFloat = 0;
    
    var body: some View {
        ZStack{
            //BackGround
            Image("BG")
                .resizable()
                .edgesIgnoringSafeArea(.all)
            
            // Banner
            ZStack {
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width, height: 100)
                    .foregroundStyle(Color.accentColor)
                    .shadow(radius: 5, y: 8)
                
                Text("Question")
                    .font(.custom("ProhibitionTest-RoughOblique", size: 85))
                    .foregroundStyle(Color.white)
                    .lineSpacing(-10)
                    .offset(y: -9)
            }
            .offset(y: -UIScreen.main.bounds.height / 2 + 100)
            
            //ForeGround
            VStack{
                Spacer()
                let players = getPlayersAsk(index: counter)
                Text("\(players[0]) ask\n\(players[1])")
                    .font(.custom("ProhibitionTest-RoughOblique", size: 45))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.white)
                    .lineSpacing(-10)
                
                ZStack{
                    Image("BlankPaper")
                        .resizable()
                        .frame(width: 656.0/2.1, height: 856.0/2.2)
                        .offset(x:15)
                        .overlay(
                            Text(questionList[topicIndex][rNum])
                                .font(.custom("ProhibitionTest-Rough", size: 30))
                                .foregroundStyle(Color.accentColor)
                                .offset(y:-40)
                                .frame(width: 200, height: 400)
                        )
                    
                    Image("CaseFileAssign")
                        .resizable()
                        .frame(width: 656.0/2.1, height: 856.0/2.2)
                        .offset(x:15)
                        .gesture(
                            TapGesture()
                                .onEnded { // Executes when the tap gesture ends
                                    animateSlideCaseFile();
                                }
                        )
                        .offset(y:slideOffsetY)
                    
                }
                
                //Done Button
                ZStack{
                    Image(nextButtonImage)
                        .gesture(DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if value.startLocation == value.location {
                                    nextButtonPress()
                                }
                            }
                            .onEnded { _ in
                                // Handle release action (when the touch ends)
                                nextButtonRelease()
                            }
                        )
                    Text("Done")
                        .font(.custom("ProhibitionTest-Regular", size: 56))
                        .padding(.bottom, 45.0)
                        .foregroundStyle(.black)
                        .allowsHitTesting(false) // Ignore user interactions
                }
                .offset(y: nextButtonVert-20)
            }
            .offset(y:40)
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
            if (CategoryHandler.shared.getSelectedCategoryIndex() > -1) {
                topicIndex = CategoryHandler.shared.getSelectedCategoryIndex()
            }
            
            animateCircleGrow() // Start the animation when the view appears
        }
    }
    
    func getPlayersAsk(index: Int) -> [String] {
        var players:[String] = ["", ""]
        let max = PlayerHandler.shared.getPlayerAmount()
        
        if index+1 < max {
            players[0] = PlayerHandler.shared.getPlayer(index: index)
            players[1] = PlayerHandler.shared.getPlayer(index: index+1)
        } else {
            players[0] = PlayerHandler.shared.getPlayer(index: max-1)
            players[1] = PlayerHandler.shared.getPlayer(index: 0)
        }
        
        return players
    }
    
    func nextButtonPress() {
        nextButtonImage = "Button_Press";
        nextButtonVert = 5.0;
    }
    
    func nextButtonRelease() {
        nextButtonImage = "Button";
        nextButtonVert = 0;
        if (slideOffsetY != 0.0) {
            animateSlideCaseFileInverse()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                counter += 1
            }
        } else {
            counter += 1
        }
        
        if counter > PlayerHandler.shared.getPlayerAmount()-1 && !repeatedCheck {
            counter = 0;
            repeatedCheck = true;
        } else if counter > PlayerHandler.shared.getPlayerAmount()-1 && repeatedCheck {
            nextScreen()
        }
    }
    
    func animateSlideCaseFile() {
        withAnimation(.easeIn(duration: 0.7)) {
            slideOffsetY = UIScreen.main.bounds.height
        }
        withAnimation(.easeOut(duration: 0.0)) {
            rNum = Int.random(in: 1..<15)
        }
    }
    func animateSlideCaseFileInverse() {
        withAnimation(.bouncy(duration: 0.7)) {
            slideOffsetY = 0
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

func readFileIntoArray(fileName: String, fileType: String) -> [[String]] {
    // Get the file path from the app's bundle
    guard let filePath = Bundle.main.path(forResource: fileName, ofType: fileType) else {
        print("File not found!")
        return []
    }
    
    do {
        // Read the file content
        let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
        
        // Split into lines
        let lines = fileContents.components(separatedBy: .newlines)
        
        var resultArray: [[String]] = []
        var currentGroup: [String] = []
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine.starts(with: "-") {
                // Save the current group if not empty
                if !currentGroup.isEmpty {
                    resultArray.append(currentGroup)
                }
                // Start a new group with the title
                currentGroup = [String(trimmedLine.dropFirst())]
            } else if !trimmedLine.isEmpty {
                // Add item to the current group
                currentGroup.append(trimmedLine)
            }
        }
        
        // Append the last group if it exists
        if !currentGroup.isEmpty {
            resultArray.append(currentGroup)
        }
    
        return resultArray
        
    } catch {
        print("Error reading file: \(error)")
        return []
    }
}


#Preview {
    Question(
        onStartGame: {}
    )
}
