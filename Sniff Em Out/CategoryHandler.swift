//
//  CategoryHandler.swift
//  Sniff Em Out
//
//  Created by Luca Mazzotta on 2025-01-19.
//

import Foundation

class CategoryHandler {
    static let shared = CategoryHandler() // Singleton instance
    
    private var categoryNames: [[String]] = [[]];
    private var categoryAmount = 0;
    
    private var selectedCategoryIndex = 0;
    
    private var selectedItemIndex: Int = 0;
    
    private init() {// Automatically load categories from file when the CategoryHandler is initialized
        categoryNames = readFileIntoArray(fileName: "categoryIndex", fileType: "txt")
        categoryAmount = categoryNames.count // Set the amount based on the number of categories loaded
    }
    
    func getCategory(index: Int) -> String {
        return categoryNames[index][0];
    }
    
    func getCategoryAmount() -> Int {
        return categoryAmount;
    }
    
    func getSelectedCategoryIndex() -> Int {
        return selectedCategoryIndex;
    }
    
    func getSelectedCategory() -> String {
            return categoryNames[selectedCategoryIndex][0];
    }
    
    func getSelectedItemIndex() -> Int {
        return selectedItemIndex;
    }
    
    func getSelectedItem() -> String {
            return categoryNames[selectedCategoryIndex][selectedItemIndex];
    }
    
    func getRandomItem(index: Int) -> String {
        return categoryNames[selectedCategoryIndex][index]
    }
    
    func getArrayMaxLength() -> Int {
        return categoryNames[selectedCategoryIndex].count;
    }
    
    func setSelectedCategoryIndex(_ index: Int) {
        selectedCategoryIndex = index;
    }
    
    func setSelectedItemIndex(_ index: Int) {
        selectedItemIndex = index;
    }
    
    func getCategoryTitlesList() -> [String] {
        var result: [String] = [];
        for i in 0..<categoryAmount {
            result.append(categoryNames[i][0]);
        }
        return result;
    }
    
    func getCategories() -> [[String]] {
        return categoryNames;
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
}
