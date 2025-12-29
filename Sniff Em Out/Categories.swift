//
//  Categories.swift
//  Sniff Em Out
//
//  Created by Luca Mazzotta on 2025-01-18.
//

import SwiftUI
import UIKit

struct Categories: View {
    var onStartGame: () -> Void // Callback for starting the game
    
    @State var circleScale: CGFloat = 0.0 // Scale of the circle for the transition
    @State var categories: [String] = CategoryHandler.shared.getCategoryTitlesList();
    @State var selectedCategory: Int = -1;
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
                
                Text("Categories")
                    .font(.custom("ProhibitionTest-RoughOblique", size: 85))
                    .foregroundStyle(Color.white)
                    .offset(y: -9)
            }
            .offset(y: -UIScreen.main.bounds.height / 2 + 100)
            
            // ForeGround
            VStack {
                ScrollView(.vertical) {
                    // Calls to sub expressions
                    categoriesStack();
                }
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.vertical, 14.0)
                .padding(.horizontal, 4.0)
                .background(Color.accentColor.opacity(0.3))
                .cornerRadius(20)
                .frame(width: UIScreen.main.bounds.width - 45, height: 460)
                .offset(y:92)
                .shadow(radius: 5, y: 8)
                
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
                .offset(y: 90+readyButtonVert)
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
    
    
    // Sub-expression breakup
    func categoriesStack() -> some View {
        HStack(){
            ForEach(1...2, id: \.self) { indexOuter in
                categoriesVerticle(indexOuter)
            }
        }
    }
    
    func categoriesVerticle(_ indexOuter: Int) -> some View {
        VStack(spacing: 20) {
            ForEach(1...12/2, id: \.self) { index in
                let categoryI:Int = indexFinder(index:index, indexOuter:indexOuter)
                buttonStyle(categoryI)
            }
        }
    }
    
    func indexFinder(index: Int, indexOuter: Int) -> Int {
        return (index+((indexOuter-1)*6))
    }
    
    func buttonStyle(_ categoryI: Int) -> some View {
        Button(categories[categoryI-1]){
            print("\(categories[categoryI-1]) Clicked");
            selectCategory(index: categoryI-1);
        }
        .frame(width: (UIScreen.main.bounds.width - 45 - 30)/2, height: 90)
        .foregroundStyle(Color.black)
        .background(isSelected(index: categoryI-1) ? Color.whiteColour : Color.gray)
        .cornerRadius(10)
        .font(.custom("ProhibitionTest-Regular", size: 30))
        .foregroundStyle(Color.accentColor)
        .padding(.horizontal, 5)
        .buttonStyle(PlainButtonStyle())
    }
    
    func isSelected(index: Int) -> Bool {
        return index == selectedCategory ? false : true;
    }
    
    func selectCategory(index: Int) {
        selectedCategory = index;
        CategoryHandler.shared.setSelectedCategoryIndex(index);
    }
    
    func readyButtonPress(){
        readyButtonImage = "Button_Press";
        readyButtonVert = 5.0;
    }
    func readyButtonRelease(){
        readyButtonImage = "Button";
        readyButtonVert = 0;
        animateCircleShrink();
        
        let arrayTemp = CategoryHandler.shared.getCategories()
        let range = arrayTemp[1].count - 1
        
        let rNum: Int = Int.random(in: 1...range);
        CategoryHandler.shared.setSelectedItemIndex(rNum);
        
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
}

#Preview {
    Categories(onStartGame: {})
}
