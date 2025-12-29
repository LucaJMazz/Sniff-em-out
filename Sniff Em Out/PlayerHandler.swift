//
//  PlayerHandler.swift
//  Sniff Em Out
//
//  Created by Luca Mazzotta on 2025-01-18.
//

import Foundation

class PlayerHandler {
    static let shared = PlayerHandler() // Singleton instance
    
    private init() {} // Prevents external initialization
    
    private var playerNames: [String] = ["","",""]
    private var playerRoles: [Int] = Array(repeating: -1, count: 3)
    private var playerAmount = 3;
    
    func addPlayer(){
        if(playerAmount<=15) {
            playerAmount+=1;
            playerNames.append("")
        } else {
            print("Error, maximum 15 players allowed")
        }
    }
    
    func removeLastPlayer(){
        if(playerAmount>=3) {
            playerAmount-=1;
            playerNames.removeLast()
        } else {
            print("Error, minimum 3 players allowed")
        }
    }
    
    func setPlayer(name: String, index: Int){
        playerNames[index] = name
    }
    
    /**
        Creates array of roles starting 3,2,0,0...0 for however many players
        Then randomzies the array to randomzie the roles for each player
     */
    func assignRoles() {
        playerRoles = Array(repeating: 0, count: playerAmount)
        playerRoles[0] = 3;
        playerRoles[1] = 2;
        
        playerRoles.shuffle();
    }
    
    func getRoles() -> [Int] {
        return playerRoles
    }
    func getRoleIndex(index: Int) -> Int {
        return playerRoles[index]
    }
    func getRoleString(index: Int) -> String {
        let role = getRoleIndex(index: index)
        var roleString = ""
        switch(role) {
        case 3: roleString = "The Mole"
            break
        case 2: roleString = "The Detective"
            break
        default: roleString = "An Associate"
            break
        }
        
        return roleString
    }
    
    func getMolesName() -> String {
        var mole: String = ""
        for i in 0..<playerAmount {
            if(getRoleIndex(index: i) == 3) {
                mole = playerNames[i]
            }
        }
        return mole
    }
    
    func getPlayerAmount() -> Int {
        return playerAmount
    }
    func setPlayerAmount(amount: Int) {
        playerAmount = amount
    }
    func getPlayer(index: Int) -> String {
        return playerNames[index]
    }
    
    func getPlayerNames() -> [String] {
        return playerNames
    }
    func setPlayerNames(_ names: [String]) {
        playerNames = names
    }
}
